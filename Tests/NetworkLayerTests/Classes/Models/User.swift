//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

struct User: Codable {
    let id: Int
    let login: String?
    let avatarUrl: String?
    let type: String?
}
