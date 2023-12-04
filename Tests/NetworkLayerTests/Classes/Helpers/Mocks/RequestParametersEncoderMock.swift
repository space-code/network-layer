//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
@testable import NetworkLayer

final class RequestParametersEncoderMock: IRequestParametersEncoder {
    var invokedEncode = false
    var invokedEncodeCount = 0
    var invokedEncodeParameters: (parameters: [String: String], request: URLRequest)?
    var invokedEncodeParametersList = [(parameters: [String: String], request: URLRequest)]()
    var stubbedEncodeError: Error?

    func encode(parameters: [String: String], to request: inout URLRequest) throws {
        invokedEncode = true
        invokedEncodeCount += 1
        invokedEncodeParameters = (parameters, request)
        invokedEncodeParametersList.append((parameters, request))
        if let error = stubbedEncodeError {
            throw error
        }
    }
}
