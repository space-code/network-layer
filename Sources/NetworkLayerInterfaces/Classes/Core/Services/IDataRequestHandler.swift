//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

/// A protocol for handling data requests.
public protocol IDataRequestHandler: URLSessionTaskDelegate & URLSessionDataDelegate {
    /// Starts a data task for handling network requests.
    ///
    /// - Parameters:
    ///   - task: The `URLSessionDataTask` representing the network task to be initiated.
    ///   - session: The `URLSession` to use for the data task.
    ///   - delegate: An optional `URLSessionDelegate` for handling `URLSession` events and callbacks. Pass `nil` if not needed.
    ///
    /// - Returns: An asynchronous task that will result in a Response object containing data when the request is completed.
    func startDataTask(
        _ task: URLSessionDataTask,
        session: URLSession,
        delegate: URLSessionDelegate?
    ) async throws -> Response<Data>
}
