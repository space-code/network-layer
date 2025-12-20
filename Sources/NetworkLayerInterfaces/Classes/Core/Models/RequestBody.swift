//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

/// Represents the supported types of HTTP request bodies.
///
/// `RequestBody` provides multiple ways to supply a request payload,
/// depending on how the data is structured or generated.
public enum RequestBody {
    /// Raw binary data used directly as the request body.
    case data(Data)

    /// A value conforming to `Encodable` that will be serialized
    /// (typically to JSON) before being sent.
    case encodable(Encodable)

    /// A dictionary-based request body.
    case dictionary([String: Any])
}
