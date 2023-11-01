//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

public protocol IRequest {
    /// Base url to the resource.
    var domainName: String { get }

    /// Endpoint path.
    var path: String { get }

    /// A dictonary that contains the parameters that will be encoded into request's header.
    var headers: [String: String]? { get }

    /// A dictionary that contains the parameters that will be encoded into request.
    var parameters: [String: String]? { get }

    /// A Boolean value indicating whether the requires authentication.
    var requiresAuthentification: Bool { get }

    /// Request's timeout.
    var timeoutInterval: TimeInterval { get }
}
