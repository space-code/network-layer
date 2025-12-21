//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import Typhoon

// MARK: - IRequestProcessor

/// A type capable of performing network requests.
public protocol IRequestProcessor {
    /// Sends a network request.
    ///
    /// - Parameters:
    ///   - request: The request object conforming to the `IRequest` protocol, representing the network request to be sent.
    ///   - delegate: An optional `URLSessionDelegate` for handling `URLSession` events and callbacks. Pass `nil` if not needed.
    ///   - configure: An optional closure that allows custom configuration of the URLRequest before sending the request.
    ///                Pass `nil` if not
    /// needed.
    func send<M: Decodable>(
        _ request: some IRequest,
        strategy: RetryPolicyStrategy?,
        delegate: URLSessionDelegate?,
        configure: (@Sendable (inout URLRequest) throws -> Void)?,
        shouldRetry: (@Sendable (Error) -> Bool)?
    ) async throws -> Response<M>
}

extension IRequestProcessor {
    /// Sends a network request with default parameters.
    ///
    /// - Parameters:
    ///   - request: The request object conforming to the `IRequest` protocol, representing the network request to be sent.
    func send<M: Decodable>(
        _ request: some IRequest,
        strategy: RetryPolicyStrategy?
    ) async throws -> Response<M> {
        try await send(request, strategy: strategy, delegate: nil, configure: nil, shouldRetry: nil)
    }

    /// Sends a network request with default parameters.
    ///
    /// - Parameters:
    ///   - request: The request object conforming to the `IRequest` protocol, representing the network request to be sent.
    func send<M: Decodable>(_ request: some IRequest) async throws -> Response<M> {
        try await send(request, strategy: nil, delegate: nil, configure: nil, shouldRetry: nil)
    }
}
