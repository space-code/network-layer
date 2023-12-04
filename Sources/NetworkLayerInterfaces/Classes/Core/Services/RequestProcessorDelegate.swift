//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

// MARK: - RequestProcessorDelegate

/// A protocol to define the delegate methods for handling network requests.
public protocol RequestProcessorDelegate: AnyObject {
    /// Notifies the delegate that the request processor is about to send a request.
    ///
    /// - Parameters:
    ///   - requestProcessor: The request processor responsible for handling the request.
    ///   - request: The URLRequest about to be sent.
    func requestProcessor(_ requestProcessor: IRequestProcessor, willSendRequest request: URLRequest) async throws

    /// Notifies the delegate that the request processor received a response and provides an opportunity to validate it.
    ///
    /// - Parameters:
    ///   - requestProcessor: The request processor responsible for handling the request.
    ///   - response: The HTTPURLResponse received from the server.
    ///   - data: The data received in the response.
    ///   - task: The URLSessionTask associated with the request.
    func requestProcessor(
        _ requestProcessor: IRequestProcessor,
        validateResponse response: HTTPURLResponse,
        data: Data,
        task: URLSessionTask
    ) throws
}

public extension RequestProcessorDelegate {
    func requestProcessor(_: IRequestProcessor, willSendRequest _: URLRequest) async throws {}
}
