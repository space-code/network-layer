//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces

final class RequestProcessorDelegateMock: RequestProcessorDelegate {
    var invokedRequestProcessor = false
    var invokedRequestProcessorCount = 0
    var invokedRequestProcessorParameters: (requestProcessor: IRequestProcessor, request: URLRequest)?
    var invokedRequestProcessorParametersList = [(requestProcessor: IRequestProcessor, request: URLRequest)]()

    func requestProcessor(_ requestProcessor: IRequestProcessor, willSendRequest request: URLRequest) async throws {
        invokedRequestProcessor = true
        invokedRequestProcessorCount += 1
        invokedRequestProcessorParameters = (requestProcessor, request)
        invokedRequestProcessorParametersList.append((requestProcessor, request))
    }

    var invokedRequestProcessorValidateResponse = false
    var invokedRequestProcessorValidateResponseCount = 0
    var invokedRequestProcessorValidateResponseParameters: (
        requestProcessor: IRequestProcessor,
        response: HTTPURLResponse,
        data: Data,
        task: URLSessionTask
    )?
    var invokedRequestProcessorValidateResponseParametersList = [(
        requestProcessor: IRequestProcessor,
        response: HTTPURLResponse,
        data: Data,
        task: URLSessionTask
    )]()
    var stubbedRequestProcessorValidateResponseError: Error?

    func requestProcessor(
        _ requestProcessor: IRequestProcessor,
        validateResponse response: HTTPURLResponse,
        data: Data,
        task: URLSessionTask
    ) throws {
        invokedRequestProcessorValidateResponse = true
        invokedRequestProcessorValidateResponseCount += 1
        invokedRequestProcessorValidateResponseParameters = (requestProcessor, response, data, task)
        invokedRequestProcessorValidateResponseParametersList.append((requestProcessor, response, data, task))
        if let error = stubbedRequestProcessorValidateResponseError {
            throw error
        }
    }
}
