//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces

// MARK: - RequestProcessor

actor RequestProcessor {
    // MARK: Properties

    private let configuration: Configuration
    private let session: URLSession
    private let dataRequestHandler: any IDataRequestHandler

    private let requestBuilder: IRequestBuilder

    struct Configuration {
        let sessionConfiguration: URLSessionConfiguration
        let sessionDelegate: URLSessionDelegate?
        let sessionDelegateQueue: OperationQueue?
        let jsonDecoder: JSONDecoder
    }

    // MARK: Initialization

    init(configuration: Configuration, requestBuilder: IRequestBuilder, dataRequestHandler: any IDataRequestHandler) {
        self.configuration = configuration
        self.requestBuilder = requestBuilder
        self.dataRequestHandler = dataRequestHandler
        session = URLSession(
            configuration: configuration.sessionConfiguration,
            delegate: dataRequestHandler,
            delegateQueue: configuration.sessionDelegateQueue
        )
    }

    // MARK: Private

    private func performRequest<T: IRequest>(
        _ request: T,
        delegate: URLSessionDelegate?,
        configure _: ((inout URLRequest) throws -> Void)?
    ) async throws -> Response<Data> {
        guard let request = requestBuilder.build(request) else {
            throw URLError(URLError.badURL)
        }

        return try await performRequest {
            let task = session.dataTask(with: request)

            do {
                let response = try await dataRequestHandler.startDataTask(task, session: session, delegate: delegate)
                return response
            } catch {
                throw URLError(URLError.cancelled)
            }
        }
    }

    private func performRequest<T>(attempts _: Int = 1, _ send: () async throws -> T) async throws -> T {
        do {
            return try await send()
        } catch {
            throw error
        }
    }
}

// MARK: IRequestProcessor

extension RequestProcessor: IRequestProcessor {
    func send<T: IRequest, M: Decodable>(
        _ request: T,
        delegate: URLSessionDelegate? = nil,
        configure: ((inout URLRequest) throws -> Void)? = nil
    ) async throws -> M {
        let response = try await performRequest(request, delegate: delegate, configure: configure)
        let item = try configuration.jsonDecoder.decode(M.self, from: response.data)
        return item
    }
}
