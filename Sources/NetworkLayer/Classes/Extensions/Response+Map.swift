//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces

extension Response {
    func map<U>(_ closure: @escaping (T) throws -> U) rethrows -> Response<U> {
        try Response<U>(data: closure(data), response: response, task: task)
    }
}
