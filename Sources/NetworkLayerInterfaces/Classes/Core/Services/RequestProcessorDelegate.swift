//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

/// A protocol to define the delegate methods for handling network requests.
public protocol RequestProcessorDelegate: AnyObject {
    /// Notifies the delegate that the request processor is about to send a request.
    ///
    /// - Parameters:
    ///   - requestProcessor: The request processor responsible for handling the request.
    ///   - request: The URLRequest about to be sent.
    func requestProcessor(_ requestProcessor: IRequestProcessor, willSendRequest request: URLRequest) async throws
}
