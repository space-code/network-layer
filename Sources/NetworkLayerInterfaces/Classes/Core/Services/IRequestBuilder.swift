//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

/// A type that creates a `URLRequest`.
public protocol IRequestBuilder {
    /// Creates a new `URLRequest` using `IRequest.`
    ///
    /// - Parameter request: The request object that defines the request details.
    ///
    /// - Returns: A `URLRequest` constructed based on the given data.
    func build(_ request: IRequest, _ configure: ((inout URLRequest) throws -> Void)?) -> URLRequest?
}
