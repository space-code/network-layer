//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces

final class RequestBuilderMock: IRequestBuilder, @unchecked Sendable {
    var invokedBuild = false
    var invokedBuildCount = 0
    var invokedBuildParameters: (request: IRequest, Void)?
    var invokedBuildParametersList = [(request: IRequest, Void)]()
    var stubbedBuildConfigureResult: (URLRequest, Void)?
    var stubbedBuildResult: URLRequest!

    func build(_ request: IRequest, _ configure: ((inout URLRequest) throws -> Void)?) -> URLRequest? {
        invokedBuild = true
        invokedBuildCount += 1
        invokedBuildParameters = (request, ())
        invokedBuildParametersList.append((request, ()))
        if var result = stubbedBuildConfigureResult {
            try? configure?(&result.0)
        }
        return stubbedBuildResult
    }
}
