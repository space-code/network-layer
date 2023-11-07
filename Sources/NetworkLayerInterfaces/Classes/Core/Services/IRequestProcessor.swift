//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

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
    func send<T: IRequest, M: Decodable>(
        _ request: T,
        delegate: URLSessionDelegate?,
        configure: ((inout URLRequest) throws -> Void)?
    ) async throws -> M
}

extension IRequestProcessor {
    /// Sends a network request with default parameters.
    ///
    /// - Parameters:
    ///   - request: The request object conforming to the `IRequest` protocol, representing the network request to be sent.
    func send<T: IRequest, M: Decodable>(
        _ request: T
    ) async throws -> M {
        try await send(request, delegate: nil, configure: nil)
    }
}
