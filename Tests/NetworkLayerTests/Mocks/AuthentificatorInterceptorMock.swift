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

    func adapt(request: inout URLRequest, for session: URLSession) async throws {
        invokedAdapt = true
        invokedAdaptCount += 1
        invokedAdaptParameters = (request, session)
        invokedAdaptParametersList.append((request, session))
    }

    var invokedRefresh = false
    var invokedRefreshCount = 0
    var invokedRefreshParameters: (request: URLRequest, response: HTTPURLResponse, session: URLSession, error: Error)?
    var invokedRefreshParametersList = [(request: URLRequest, response: HTTPURLResponse, session: URLSession, error: Error)]()

    func refresh(_ request: URLRequest, with response: HTTPURLResponse, for session: URLSession, dutTo error: Error) async throws {
        invokedRefresh = true
        invokedRefreshCount += 1
        invokedRefreshParameters = (request, response, session, error)
        invokedRefreshParametersList.append((request, response, session, error))
    }
}
