//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces

/// A type defines the interface for the request body encoder.
protocol IRequestBodyEncoder {
    /// Encodes parameters into the request body.
    ///
    /// - Parameters:
    ///   - body: The parameters to be encoded.
    ///   - request: The request.
    func encode(body: RequestBody, to request: inout URLRequest) throws
}
