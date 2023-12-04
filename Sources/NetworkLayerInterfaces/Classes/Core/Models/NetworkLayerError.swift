//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

/// `NetworkLayerError` is the error type returned by NetworkLayer.
public enum NetworkLayerError: Swift.Error {
    /// A malformed URL prevented a URL request from being initiated.
    case badURL
}
