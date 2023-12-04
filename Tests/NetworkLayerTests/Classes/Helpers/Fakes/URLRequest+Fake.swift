//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

extension URLRequest {
    static func fake(string: String = "https://google.com/") -> URLRequest {
        URLRequest(url: URL(string: string)!)
    }
}
