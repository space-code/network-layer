//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import Typhoon

final class RetryPolicyServiceMock<T>: IRetryPolicyService {
    var invokedRetry = false
    var invokedRetryCount = 0
    var invokedRetryParameters: (strategy: RetryPolicyStrategy?, closure: Void)?
    var invokedRetryParametersList = [(strategy: RetryPolicyStrategy?, closure: Void)]()
    var stubbedRetry: T!

    func retry<T>(strategy: RetryPolicyStrategy?, _: () async throws -> T) async throws -> T {
        invokedRetry = true
        invokedRetryCount += 1
        invokedRetryParameters = (strategy, ())
        invokedRetryParametersList.append((strategy, ()))
        return stubbedRetry as! T
    }
}
