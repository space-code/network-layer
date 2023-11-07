//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

/// A type to which all requests must conform.
public protocol IRequest {
    /// The base `URL` for the resource.
    var domainName: String { get }

    /// The endpoint path.
    var path: String { get }

    /// A dictionary that contains the parameters to be encoded into the request's header.
    var headers: [String: String]? { get }

    /// A dictionary that contains the parameters to be encoded into the request.
    var parameters: [String: String]? { get }

    /// A Boolean value indicating whether authentication is required.
    var requiresAuthentication: Bool { get }

    /// Request's timeout interval.
    var timeoutInterval: TimeInterval { get }

    /// The HTTP method.
    var httpMethod: HTTPMethod { get }

    /// A dictonary that contains the request's body.
    var httpBody: [String: Any]? { get }
}
