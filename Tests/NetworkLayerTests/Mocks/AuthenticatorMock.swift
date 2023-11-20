//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces

final class AuthenticatorMock: IAuthenticator {
    typealias Credential = AuthenticationCredentialStub

    var invokedApply = false
    var invokedApplyCount = 0
    var invokedApplyParameters: (credential: Credential, urlRequest: URLRequest)?
    var invokedApplyParametersList = [(credential: Credential, urlRequest: URLRequest)]()

    func apply(_ credential: Credential, to urlRequest: URLRequest) async throws {
        invokedApply = true
        invokedApplyCount += 1
        invokedApplyParameters = (credential, urlRequest)
        invokedApplyParametersList.append((credential, urlRequest))
    }

    var invokedRefresh = false
    var invokedRefreshCount = 0
    var invokedRefreshParameters: (credential: Credential, session: URLSession)?
    var invokedRefreshParametersList = [(credential: Credential, session: URLSession)]()
    var stubbedRefresh: Credential!

    func refresh(_ credential: Credential, for session: URLSession) async throws -> Credential {
        invokedRefresh = true
        invokedRefreshCount += 1
        invokedRefreshParameters = (credential, session)
        invokedRefreshParametersList.append((credential, session))
        return stubbedRefresh
    }

    var invokedDidRequest = false
    var invokedDidRequestCount = 0
    var invokedDidRequestParameters: (urlRequest: URLRequest, response: HTTPURLResponse)?
    var invokedDidRequestParametersList = [(urlRequest: URLRequest, response: HTTPURLResponse)]()
    var stubbedDidRequestResult: Bool! = false

    func didRequest(_ urlRequest: URLRequest, with response: HTTPURLResponse) -> Bool {
        invokedDidRequest = true
        invokedDidRequestCount += 1
        invokedDidRequestParameters = (urlRequest, response)
        invokedDidRequestParametersList.append((urlRequest, response))
        return stubbedDidRequestResult
    }

    var invokedIsRequest = false
    var invokedIsRequestCount = 0
    var invokedIsRequestParameters: (urlRequest: URLRequest, credential: Credential)?
    var invokedIsRequestParametersList = [(urlRequest: URLRequest, credential: Credential)]()
    var stubbedIsRequestResult: Bool! = false

    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: Credential) -> Bool {
        invokedIsRequest = true
        invokedIsRequestCount += 1
        invokedIsRequestParameters = (urlRequest, credential)
        invokedIsRequestParametersList.append((urlRequest, credential))
        return stubbedIsRequestResult
    }
}
