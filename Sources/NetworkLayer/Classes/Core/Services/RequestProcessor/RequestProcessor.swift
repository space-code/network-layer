//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces
import Typhoon

// MARK: - RequestProcessor

/// An actor responsible for executing network requests in a thread-safe manner.
///
/// `RequestProcessor` manages the entire lifecycle of a request, including construction,
/// authentication adaptation, execution, credential refreshing, and retry logic.
actor RequestProcessor {
    // MARK: - Properties

    /// The network layer's configuration containing session settings and decoders.
    private let configuration: Configuration

    /// The underlying `URLSession` used to manage data transfer tasks.
    private let session: URLSession

    /// The handler responsible for managing the state and events of a specific data task.
    private let dataRequestHandler: any IDataRequestHandler

    /// The component used to transform `IRequest` models into `URLRequest` objects.
    private let requestBuilder: IRequestBuilder

    /// An optional service that handles request retries based on specific strategies.
    private let retryPolicyService: IRetryPolicyService?

    /// An optional interceptor for modifying requests and handling authentication challenges.
    private let interceptor: IAuthenticationInterceptor?

    /// A thread-safe delegate for observing and validating request processor events.
    private var delegate: SafeRequestProcessorDelegate?

    /// A global evaluator to determine if a retry should be attempted based on the error.
    /// This applies to all requests processed by this instance.
    private let retryEvaluator: (@Sendable (Error) -> RetryAction)?

    // MARK: - Initialization

    /// Creates a new `RequestProcessor` instance.
    ///
    /// - Parameters:
    ///   - configuration: The network layer's configuration.
    ///   - requestBuilder: The request builder.
    ///   - dataRequestHandler: The data request handler.
    ///   - retryPolicyService: The retry policy service.
    ///   - delegate: A thread-safe delegate for processor events.
    ///   - interceptor: An authenticator interceptor.
    init(
        configuration: Configuration,
        requestBuilder: IRequestBuilder,
        dataRequestHandler: any IDataRequestHandler,
        retryPolicyService: IRetryPolicyService?,
        delegate: SafeRequestProcessorDelegate?,
        interceptor: IAuthenticationInterceptor?,
        retryEvaluator: (@Sendable (Error) -> RetryAction)?
    ) {
        self.configuration = configuration
        self.requestBuilder = requestBuilder
        self.dataRequestHandler = dataRequestHandler
        self.retryPolicyService = retryPolicyService
        self.delegate = delegate
        self.interceptor = interceptor
        self.retryEvaluator = retryEvaluator

        self.dataRequestHandler.urlSessionDelegate = configuration.sessionDelegate

        session = URLSession(
            configuration: configuration.sessionConfiguration,
            delegate: dataRequestHandler,
            delegateQueue: configuration.sessionDelegateQueue
        )
    }

    // MARK: - Private Methods

    /// Orchestrates the execution of a network request, including building, adaptation, and error handling.
    ///
    /// - Parameters:
    ///   - request: The network request model.
    ///   - strategy: An optional override for the retry policy strategy.
    ///   - delegate: A delegate to handle session-level events.
    ///   - configure: A closure for final modifications to the `URLRequest`.
    /// - Returns: A `Response` object containing the raw `Data`.
    private func performRequest(
        _ request: some IRequest,
        strategy: RetryPolicyStrategy? = nil,
        delegate: URLSessionDelegate?,
        configure: (@Sendable (inout URLRequest) throws -> Void)?,
        shouldRetry: (@Sendable (Error) -> RetryAction)?
    ) async throws -> Response<Data> {
        try await performRequest(
            strategy: strategy,
            send: { [weak self] in
                guard let self else { throw NetworkLayerError.badURL }
                return try await execute(request, delegate: delegate, configure: configure)
            }, shouldRetry: { [weak self] error in
                guard let self else { return .stop }
                return await handleRetry(error, shouldRetry: shouldRetry)
            }
        )
    }

    /// Modifies the `URLRequest` to include authentication credentials if required.
    ///
    /// - Parameters:
    ///   - request: The initial request model.
    ///   - urlRequest: The `URLRequest` being prepared for transport.
    ///   - session: The current `URLSession`.
    private func adapt(_ request: some IRequest, urlRequest: inout URLRequest, session: URLSession) async throws {
        guard request.requiresAuthentication else { return }
        try await interceptor?.adapt(request: &urlRequest, for: session)
    }

    /// Checks if a request requires a credential refresh and performs it if necessary.
    ///
    /// - Parameters:
    ///   - urlRequest: The failed or unauthorized request.
    ///   - response: The received network response.
    ///   - session: The current `URLSession`.
    /// - Returns: `true` if a refresh was triggered, `false` otherwise.
    private func refresh(
        urlRequest: URLRequest,
        response: Response<some Any>,
        session: URLSession
    ) async throws -> Bool {
        guard let interceptor, let response = response.response as? HTTPURLResponse else { return false }

        if interceptor.isRequireRefresh(urlRequest, response: response) {
            try await interceptor.refresh(urlRequest, with: response, for: session)
            return true
        }

        return false
    }

    /// Wraps a request operation with retry logic provided by the `retryPolicyService`.
    ///
    /// - Parameters:
    ///   - strategy: The strategy to apply for retries.
    ///   - send: An asynchronous closure that executes the request logic.
    ///   - shouldRetry: A closure to decide if a retry should occur based on the error.
    /// - Returns: The result of the request if successful.
    private func performRequest<T: Sendable>(
        strategy: RetryPolicyStrategy? = nil,
        send: @Sendable () async throws -> T,
        shouldRetry: @Sendable @escaping (Error) async -> RetryAction
    ) async throws -> T {
        if let retryPolicyService {
            try await retryPolicyService.retry(strategy: strategy, onFailure: shouldRetry, send)
        } else {
            try await send()
        }
    }

    /// Wraps a request operation with retry logic and returns a detailed `RetryResult`.
    ///
    /// - Parameters:
    ///   - strategy: The strategy to apply for retries.
    ///   - send: An asynchronous closure that executes the request logic.
    ///   - shouldRetry: A closure to decide if a retry should occur based on the error.
    /// - Returns: A `RetryResult` containing the result and retry metadata.
    private func performRequestWithResult<T: Sendable>(
        strategy: RetryPolicyStrategy? = nil,
        send: @Sendable () async throws -> T,
        shouldRetry: @Sendable @escaping (Error) async -> RetryAction
    ) async throws -> RetryResult<T> {
        let service = retryPolicyService ?? RetryPolicyService(strategy: .constant(retry: 0, dispatchDuration: .seconds(0)))
        return try await service.retryWithResult(strategy: strategy, onFailure: shouldRetry, send)
    }

    /// Triggers the delegate's validation logic for the received HTTP response.
    ///
    /// - Parameter response: The response object to validate.
    private func validate(_ response: Response<Data>) throws {
        guard let urlResponse = response.response as? HTTPURLResponse else { return }
        try delegate?.wrappedValue?.requestProcessor(
            self,
            validateResponse: urlResponse,
            data: response.data,
            task: response.task
        )
    }

    /// Builds and sends a URL request, applying adapters and delegate hooks,
    /// with optional token refresh on authentication failure.
    ///
    /// - Parameters:
    ///   - request: The request object conforming to `IRequest`.
    ///   - delegate: An optional `URLSessionDelegate` for task-level events.
    ///   - configure: An optional closure to mutate the `URLRequest` before sending.
    /// - Returns: A `Response<Data>` containing the raw response data.
    /// - Throws: `NetworkLayerError.badURL` if the request URL cannot be built,
    ///           or any error produced by adapters, delegate hooks, or the data task.
    private func execute(
        _ request: some IRequest,
        delegate: URLSessionDelegate?,
        configure: (@Sendable (inout URLRequest) throws -> Void)?
    ) async throws -> Response<Data> {
        var urlRequest = try requestBuilder.build(request, configure) ?? { throw NetworkLayerError.badURL }()

        try await adapt(request, urlRequest: &urlRequest, session: session)
        try await self.delegate?.wrappedValue?.requestProcessor(self, willSendRequest: urlRequest)

        var response = try await performDataTask(urlRequest: urlRequest, delegate: delegate)

        if request.requiresAuthentication {
            response = try await authenticatedRetryIfNeeded(
                urlRequest: urlRequest,
                response: response,
                delegate: delegate
            )
        }

        try validate(response)
        return response
    }

    /// Retries the request once if the initial response requires a token refresh.
    /// Throws if the response is still unauthorized after the retry.
    ///
    /// - Parameters:
    ///   - urlRequest: The original `URLRequest` to retry.
    ///   - response: The initial response received before any retry attempt.
    ///   - delegate: An optional `URLSessionDelegate` for task-level events.
    /// - Returns: The original response if no retry was needed, or the retried response on success.
    /// - Throws: `AuthenticatorInterceptorError.missingCredential` if the request
    ///           remains unauthorized after a single retry.
    private func authenticatedRetryIfNeeded(
        urlRequest: URLRequest,
        response: Response<Data>,
        delegate: URLSessionDelegate?
    ) async throws -> Response<Data> {
        guard try await refresh(urlRequest: urlRequest, response: response, session: session) else {
            return response
        }

        let retryResponse = try await performDataTask(urlRequest: urlRequest, delegate: delegate)

        guard try await !refresh(urlRequest: urlRequest, response: retryResponse, session: session) else {
            throw AuthenticatorInterceptorError.missingCredential
        }

        return retryResponse
    }

    /// Starts a data task for the given `URLRequest` and returns the response.
    ///
    /// - Parameters:
    ///   - urlRequest: The configured `URLRequest` to execute.
    ///   - delegate: An optional `URLSessionDelegate` for task-level events.
    /// - Returns: A `Response<Data>` containing the raw response data.
    private func performDataTask(
        urlRequest: URLRequest,
        delegate: URLSessionDelegate?
    ) async throws -> Response<Data> {
        let task = session.dataTask(with: urlRequest)
        return try await dataRequestHandler.startDataTask(task, delegate: delegate)
    }

    /// Resolves the final retry action by combining global and local retry evaluators.
    ///
    /// The most restrictive action takes precedence: `.stop` > `.skipDelay` > `.retry`.
    ///
    /// - Parameters:
    ///   - error: The error that triggered the retry evaluation.
    ///   - shouldRetry: An optional local closure that returns a `RetryAction` for the given error.
    /// - Returns: The resolved `RetryAction` based on both evaluators.
    private func handleRetry(
        _ error: Error,
        shouldRetry: (@Sendable (Error) -> RetryAction)?
    ) -> RetryAction {
        let globalResult = retryEvaluator?(error) ?? .retry
        let localResult = shouldRetry?(error) ?? .retry

        switch (globalResult, localResult) {
        case (_, .stop), (.stop, _):
            return .stop
        case (_, .skipDelay), (.skipDelay, _):
            return .skipDelay
        case (.retry, .retry):
            return .retry
        }
    }
}

// MARK: IRequestProcessor

extension RequestProcessor: IRequestProcessor {
    /// Sends a network request and decodes the response into a specified type.
    ///
    /// - Parameters:
    ///   - request: The request model.
    ///   - strategy: Optional retry strategy override.
    ///   - delegate: Optional session delegate.
    ///   - configure: Optional closure to modify the `URLRequest`.
    ///   - shouldRetry: Optional closure to handle specific error filtering.
    /// - Returns: A `Response` object containing the decoded model of type `M`.
    func send<M: Decodable & Sendable>(
        _ request: some IRequest,
        strategy: RetryPolicyStrategy? = nil,
        delegate: URLSessionDelegate? = nil,
        configure: (@Sendable (inout URLRequest) throws -> Void)? = nil,
        shouldRetry: (@Sendable (Error) -> RetryAction)? = nil
    ) async throws -> Response<M> {
        let response = try await performRequest(
            request,
            strategy: strategy,
            delegate: delegate,
            configure: configure,
            shouldRetry: shouldRetry
        )

        return try response.map { data in
            try self.configuration.jsonDecoder.decode(M.self, from: data)
        }
    }

    /// Sends a network request and returns the result along with retry information.
    ///
    /// - Parameters:
    ///   - request: The request object conforming to the `IRequest` protocol.
    ///   - strategy: An optional override for the retry policy strategy.
    ///   - delegate: An optional `URLSessionDelegate`.
    ///   - configure: An optional closure to modify the `URLRequest`.
    ///   - shouldRetry: An optional closure to determine if a retry should be attempted.
    /// - Returns: A retry result containing the response.
    func sendWithResult<M: Decodable & Sendable>(
        _ request: some IRequest,
        strategy: RetryPolicyStrategy? = nil,
        delegate: URLSessionDelegate? = nil,
        configure: (@Sendable (inout URLRequest) throws -> Void)? = nil,
        shouldRetry: (@Sendable (Error) -> RetryAction)? = nil
    ) async throws -> RetryResult<Response<M>> {
        try await performRequestWithResult(
            strategy: strategy,
            send: { [weak self] in
                guard let self else { throw NetworkLayerError.badURL }

                let response = try await execute(request, delegate: delegate, configure: configure)

                return try response.map { data in
                    try self.configuration.jsonDecoder.decode(M.self, from: data)
                }
            }, shouldRetry: { [weak self] error in
                guard let self else { return .stop }
                return await handleRetry(error, shouldRetry: shouldRetry)
            }
        )
    }
}
