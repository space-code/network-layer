//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

public struct Response<T> {
    public let data: T
    public let response: URLResponse
    public let task: URLSessionTask
    public let statusCode: Int?

    public init(data: T, response: URLResponse, task: URLSessionTask) {
        self.data = data
        self.response = response
        statusCode = (response as? HTTPURLResponse)?.statusCode
        self.task = task
    }
}
