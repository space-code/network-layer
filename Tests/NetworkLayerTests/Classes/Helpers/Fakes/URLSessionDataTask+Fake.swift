//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

extension URLSessionDataTask {
    @objc override dynamic
    class func fake() -> URLSessionDataTask {
        URLSession.shared.dataTask(with: .fake())
    }
}
