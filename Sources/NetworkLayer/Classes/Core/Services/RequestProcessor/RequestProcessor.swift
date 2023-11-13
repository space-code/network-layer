//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces
import Typhoon

// MARK: - RequestProcessor

actor RequestProcessor {
    // MARK: Properties

    private let configuration: Configuration
    private let session: URLSession
    private let dataRequestHandler: any IDataRequestHandler

    private let requestBuilder: IRequestBuilder
    private let retryPolicyService: IRetryPolicyService

    struct Configuration {
        let sessionConfiguration: URLSessionConfiguration
        let sessionDelegate: URLSessionDelegate?
        let sessionDelegateQueue: OperationQueue?
        let jsonDecoder: JSONDecoder
    }

    // MARK: Initialization

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

    private func performRequest<T: IRequest>(
        _ request: T,
        strategy: RetryPolicyStrategy? = nil,
        delegate: URLSessionDelegate?,
        configure _: ((inout URLRequest) throws -> Void)?
    ) async throws -> Response<Data> {
        guard let request = requestBuilder.build(request) else {
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
