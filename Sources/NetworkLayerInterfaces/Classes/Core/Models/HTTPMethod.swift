//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

/// Enum representing HTTP methods.
///
/// See https://tools.ietf.org/html/rfc7231#section-4.3
public enum HTTPMethod {
    /// `CONNECT` method.
    case connect
    /// `DELETE` method.
    case delete
    /// `GET` method.
    case get
    /// `HEAD` method.
    case head
    /// `OPTIONS` method.
    case options
    /// `PATCH` method.
    case patch
    /// `POST` method.
    case post
    /// `PUT` method.
    case put
    /// `QUERY` method.
    case query
    /// `TRACE` method.
    case trace
}
