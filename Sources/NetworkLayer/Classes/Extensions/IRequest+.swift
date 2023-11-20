//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces

extension IRequest {
    var fullPath: String? {
        if !domainName.isEmpty {
            return [domainName, path].joined(separator: "/")
        }
        return nil
    }
}
