//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

extension URLRequest {
    static func fake() -> URLRequest {
        URLRequest(url: URL(string: "https://google.com/")!)
    }
}
