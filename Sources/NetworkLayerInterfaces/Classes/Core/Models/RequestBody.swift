//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

public enum RequestBody {
    case data(Data)
    case encodable(Encodable)
    case dictonary([String: Any])
}
