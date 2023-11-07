//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

public struct Response<T> {
    public let data: T
    public let response: URLResponse

    public init(data: T, response: URLResponse) {
        self.data = data
        self.response = response
    }
}
