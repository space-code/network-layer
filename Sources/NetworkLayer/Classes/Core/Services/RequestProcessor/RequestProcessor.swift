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
        retryPolicyService: IRetryPolicyService
    ) {
        self.configuration = configuration
        self.requestBuilder = requestBuilder
        self.dataRequestHandler = dataRequestHandler
        self.retryPolicyService = retryPolicyService
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
        guard let request = requestBuilder.build(request, configure) else {
            throw NetworkLayerError.badURL
        }

        return try await performRequest(strategy: strategy) {
            let task = session.dataTask(with: request)

            do {
                return try await dataRequestHandler.startDataTask(task, session: session, delegate: delegate)
            } catch {
                throw error
            }
        }
    }

    /// Performs a request with a retry policy.
    ///
    /// - Parameters:
    ///   - strategy: The strategy for retrying the request.
    ///   - send: The closure that sends the request.
    ///
    /// - Returns: The response from the network request.
    private func performRequest<T>(
        strategy: RetryPolicyStrategy? = nil,
        _ send: () async throws -> T
    ) async throws -> T {
        try await retryPolicyService.retry(strategy: strategy, send)
    }
}

// MARK: IRequestProcessor

extension RequestProcessor: IRequestProcessor {
    func send<T: IRequest, M: Decodable>(
        _ request: T,
        strategy _: RetryPolicyStrategy? = nil,
        delegate: URLSessionDelegate? = nil,
        configure: ((inout URLRequest) throws -> Void)? = nil
    ) async throws -> M {
        let response = try await performRequest(request, delegate: delegate, configure: configure)
        let item = try configuration.jsonDecoder.decode(M.self, from: response.data)
        return item
    }
}
