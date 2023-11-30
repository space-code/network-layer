//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

extension URLSessionTask {
    @objc dynamic
    class func fake() -> URLSessionTask {
        URLSession.shared.dataTask(with: .fake())
    }
}
