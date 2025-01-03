//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import Mocker

struct StubResponse: @unchecked Sendable {
    let name: String
    let fileURL: URL
    let httpMethod: Mock.HTTPMethod
}
