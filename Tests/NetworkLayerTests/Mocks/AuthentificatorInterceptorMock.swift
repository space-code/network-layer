//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces

final class AuthentificatorInterceptorMock: IAuthenticatorInterceptor {
    var invokedAdapt = false
    var invokedAdaptCount = 0
    var invokedAdaptParameters: (request: URLRequest, session: URLSession)?
    var invokedAdaptParametersList = [(request: URLRequest, session: URLSession)]()

    func adapt(request: URLRequest, for session: URLSession) {
        invokedAdapt = true
        invokedAdaptCount += 1
        invokedAdaptParameters = (request, session)
        invokedAdaptParametersList.append((request, session))
    }

    var invokedRefresh = false
    var invokedRefreshCount = 0
    var invokedRefreshParameters: (request: URLRequest, response: HTTPURLResponse, session: URLSession)?
    var invokedRefreshParametersList = [(request: URLRequest, response: HTTPURLResponse, session: URLSession)]()

    func refresh(_ request: URLRequest, with response: HTTPURLResponse, for session: URLSession) {
        invokedRefresh = true
        invokedRefreshCount += 1
        invokedRefreshParameters = (request, response, session)
        invokedRefreshParametersList.append((request, response, session))
    }

    var invokedIsRequireRefresh = false
    var invokedIsRequireRefreshCount = 0
    var invokedIsRequireRefreshParameters: (request: URLRequest, response: HTTPURLResponse)?
    var invokedIsRequireRefreshParametersList = [(request: URLRequest, response: HTTPURLResponse)]()
    var stubbedIsRequireRefreshResult: Bool! = false

    func isRequireRefresh(_ request: URLRequest, response: HTTPURLResponse) -> Bool {
        invokedIsRequireRefresh = true
        invokedIsRequireRefreshCount += 1
        invokedIsRequireRefreshParameters = (request, response)
        invokedIsRequireRefreshParametersList.append((request, response))
        return stubbedIsRequireRefreshResult
    }
}
