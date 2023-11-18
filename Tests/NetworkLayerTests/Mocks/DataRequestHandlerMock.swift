//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces

final class DataRequestHandlerMock: NSObject, IDataRequestHandler {
    var invokedStartDataTask = false
    var invokedStartDataTaskCount = 0
    var invokedStartDataTaskParameters: (task: URLSessionDataTask, session: URLSession, delegate: URLSessionDelegate?)?
    var invokedStartDataTaskParametersList = [(task: URLSessionDataTask, session: URLSession, delegate: URLSessionDelegate?)]()
    var stubbedStartDataTask: Response<Data>!
    var startDataTaskThrowError: Error?

    func startDataTask(
        _ task: URLSessionDataTask,
        session: URLSession,
        delegate: URLSessionDelegate?
    ) async throws -> Response<Data> {
        invokedStartDataTask = true
        invokedStartDataTaskCount += 1
        invokedStartDataTaskParameters = (task, session, delegate)
        invokedStartDataTaskParametersList.append((task, session, delegate))
        if let error = startDataTaskThrowError {
            throw error
        }
        return stubbedStartDataTask
    }
}
