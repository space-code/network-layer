//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
@testable import NetworkLayer
import NetworkLayerInterfaces

final class RequestBodyEncoderMock: IRequestBodyEncoder {
    var invokedEncode = false
    var invokedEncodeCount = 0
    var invokedEncodeParameters: (body: RequestBody, request: URLRequest)?
    var invokedEncodeParametersList = [(body: RequestBody, request: URLRequest)]()
    var stubbedEncodeError: Error?

    func encode(body: RequestBody, to request: inout URLRequest) throws {
        invokedEncode = true
        invokedEncodeCount += 1
        invokedEncodeParameters = (body, request)
        invokedEncodeParametersList.append((body, request))
        if let error = stubbedEncodeError {
            throw error
        }
    }
}
