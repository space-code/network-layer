//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces

final class DataRequestHandlerMock: NSObject, IDataRequestHandler, @unchecked Sendable {
    var invokedUrlSessionGetDelegate = false
    var invokedUrlSessionGetDelegateCount = 0
    var invokedUrlSessionSetDelegate = false
    var invokedUrlSessionSetDelegateCount = 0
    var stubbedUrlSessionDelegate: URLSessionDelegate?
    var urlSessionDelegate: URLSessionDelegate? {
        get {
            invokedUrlSessionGetDelegate = true
            invokedUrlSessionGetDelegateCount += 1
            return stubbedUrlSessionDelegate
        }
        set {
            invokedUrlSessionSetDelegate = true
            invokedUrlSessionSetDelegateCount += 1
        }
    }

    var invokedStartDataTask = false
    var invokedStartDataTaskCount = 0
    var invokedStartDataTaskParameters: (task: URLSessionDataTask, delegate: URLSessionDelegate?)?
    var invokedStartDataTaskParametersList = [(task: URLSessionDataTask, delegate: URLSessionDelegate?)]()
    var stubbedStartDataTask: Response<Data>!
    var startDataTaskThrowError: Error?

    func startDataTask(
        _ task: URLSessionDataTask,
        delegate: URLSessionDelegate?
    ) async throws -> Response<Data> {
        invokedStartDataTask = true
        invokedStartDataTaskCount += 1
        invokedStartDataTaskParameters = (task, delegate)
        invokedStartDataTaskParametersList.append((task, delegate))
        if let error = startDataTaskThrowError {
            throw error
        }
        return stubbedStartDataTask
    }
}
