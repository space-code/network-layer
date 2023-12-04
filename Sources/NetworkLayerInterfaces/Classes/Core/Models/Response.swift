//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

/// A generic struct representing an HTTP response.
public struct Response<T> {
    /// The data associated with the response.
    public let data: T

    /// The URL response received.
    public let response: URLResponse

    /// The URLSessionTask associated with the response.
    public let task: URLSessionTask

    /// The HTTP status code of the response, if available.
    public let statusCode: Int?

    /// Initializes a new instance of `Response`.
    ///
    /// - Parameters:
    ///   - data: The data associated with the response.
    ///   - response: The URL response received.
    ///   - task: The URLSessionTask associated with the response.
    public init(data: T, response: URLResponse, task: URLSessionTask) {
        self.data = data
        self.response = response
        statusCode = (response as? HTTPURLResponse)?.statusCode
        self.task = task
    }
}
