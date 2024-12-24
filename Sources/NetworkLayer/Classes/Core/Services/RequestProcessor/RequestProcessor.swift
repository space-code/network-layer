//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces
import Typhoon

// MARK: - RequestProcessor

/// An object that handles request processing.
actor RequestProcessor {
    // MARK: Properties

    /// The network layer's configuration.
    private let configuration: Configuration
    /// The object that coordinates a group of related, network data transfer tasks.
    private let session: URLSession
    /// The data request handler.
    private let dataRequestHandler: any IDataRequestHandler
    /// The request builder.
    private let requestBuilder: IRequestBuilder
    /// The retry policy service.
    private let retryPolicyService: IRetryPolicyService
    /// The authenticator interceptor.
    private let interceptor: IAuthenticationInterceptor?
    /// The delegate.
    private var delegate: SafeRequestProcessorDelegate?

    // MARK: Initialization

    /// Creates a new `RequestProcessor` instance.
    ///
    /// - Parameters:
    ///   - configure: The network layer's configuration.
    ///   - requestBuilder: The request builder.
    ///   - dataRequestHandler: The data request handler.
    ///   - retryPolicyService: The retry policy service.
    init(
        configuration: Configuration,
        requestBuilder: IRequestBuilder,
        dataRequestHandler: any IDataRequestHandler,
        retryPolicyService: IRetryPolicyService,
        delegate: SafeRequestProcessorDelegate?,
        interceptor: IAuthenticationInterceptor?
    ) {
        self.configuration = configuration
        self.requestBuilder = requestBuilder
        self.dataRequestHandler = dataRequestHandler
        self.retryPolicyService = retryPolicyService
        self.delegate = delegate
        self.interceptor = interceptor
        self.dataRequestHandler.urlSessionDelegate = configuration.sessionDelegate
        session = URLSession(
            configuration: configuration.sessionConfiguration,
            delegate: dataRequestHandler,
            delegateQueue: configuration.sessionDelegateQueue
        )
    }

    // MARK: Private

    /// Performs a network request.
    ///
    /// - Parameters:
    ///   - request: The network request.
    ///   - strategy: The retry policy strategy.
    ///   - delegate: A protocol that defines methods that URL session instances call on their delegates
    ///               to handle session-level events, like session life cycle changes.
    ///   - configure: A closure to configure the URLRequest.
    ///
    /// - Returns: The response from the network request.
    private func performRequest<T: IRequest>(
        _ request: T,
        strategy: RetryPolicyStrategy? = nil,
        delegate: URLSessionDelegate?,
        configure: ((inout URLRequest) throws -> Void)?
    ) async throws -> Response<Data> {
        guard var urlRequest = try requestBuilder.build(request, configure) else {
            throw NetworkLayerError.badURL
        }

        try await adapt(request, urlRequest: &urlRequest, session: session)

        return try await performRequest(strategy: strategy) { [urlRequest] in
            try await self.delegate?.wrappedValue?.requestProcessor(self, willSendRequest: urlRequest)

            let task = session.dataTask(with: urlRequest)

            do {
                let response = try await dataRequestHandler.startDataTask(task, delegate: delegate)

                if request.requiresAuthentication {
                    let isRefreshedCredential = try await refresh(
                        urlRequest: urlRequest,
                        response: response,
                        session: session
                    )

                    if isRefreshedCredential {
                        throw AuthenticatorInterceptorError.missingCredential
                    }
                }

                try await self.validate(response)

                return response
            } catch {
                throw error
            }
        }
    }

    /// Adapts an initial request.
    ///
    /// - Parameters:
    ///   - request: The request model.
    ///   - urlRequest: The request that needs to be authenticated.
    ///   - session: The URLSession for which the request is being refreshed.
    private func adapt<T: IRequest>(_ request: T, urlRequest: inout URLRequest, session: URLSession) async throws {
        guard request.requiresAuthentication else { return }
        try await interceptor?.adapt(request: &urlRequest, for: session)
    }

    /// Refreshes credential.
    ///
    /// - Parameters:
    ///   - urlRequest: The request that needs to be authenticated.
    ///   - response: The metadata associated with the response to an HTTP protocol URL load request.
    ///   - session: The URLSession for which the request is being refreshed.
    ///
    /// - Returns: `true` if the request's token is refreshed, false otherwise.
    private func refresh<T>(
        urlRequest: URLRequest,
        response: Response<T>,
        session: URLSession
    ) async throws -> Bool {
        guard let interceptor, let response = response.response as? HTTPURLResponse else { return false }

        if interceptor.isRequireRefresh(urlRequest, response: response) {
            try await interceptor.refresh(urlRequest, with: response, for: session)
            return true
        }

        return false
    }

    /// Performs a request with a retry policy.
    ///
    /// - Parameters:
    ///   - strategy: The strategy for retrying the request.
    ///   - send: The closure that sends the request.
    ///
    /// - Returns: The response from the network request.
    private func performRequest<T: Sendable>(
        strategy: RetryPolicyStrategy? = nil,
        _ send: @Sendable () async throws -> T
    ) async throws -> T {
        do {
            return try await send()
        } catch {
            return try await retryPolicyService.retry(strategy: strategy, send)
        }
    }

    private func validate(_ response: Response<Data>) throws {
        guard let urlResponse = response.response as? HTTPURLResponse else { return }
        try delegate?.wrappedValue?.requestProcessor(
            self,
            validateResponse: urlResponse,
            data: response.data,
            task: response.task
        )
    }
}

// MARK: IRequestProcessor

extension RequestProcessor: IRequestProcessor {
    func send<T: IRequest, M: Decodable & Sendable>(
        _ request: T,
        strategy: RetryPolicyStrategy? = nil,
        delegate: URLSessionDelegate? = nil,
        configure: (@Sendable (inout URLRequest) throws -> Void)? = nil
    ) async throws -> Response<M> {
        let response = try await performRequest(request, strategy: strategy, delegate: delegate, configure: configure)
        return try response.map { data in try self.configuration.jsonDecoder.decode(M.self, from: data) }
    }
}
