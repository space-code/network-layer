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
}
