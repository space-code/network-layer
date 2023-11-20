//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces

extension IRequest {
    var fullPath: String {
        [domainName, path].joined(separator: "/")
    }
}
