//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

/// A type defines the interface for the request parameters encoder.
protocol IRequestParametersEncoder {
    /// Encodes parameters into the request query.
    ///
    /// - Parameters:
    ///   - parameters: The parameters to be encoded.
    ///   - request: The request.
    func encode(parameters: [String: String], to request: inout URLRequest) throws
}
