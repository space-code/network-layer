//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces

final class RequestMock: IRequest, @unchecked Sendable {
    var invokedDomainNameGetter = false
    var invokedDomainNameGetterCount = 0
    var stubbedDomainName: String! = ""

    var domainName: String {
        invokedDomainNameGetter = true
        invokedDomainNameGetterCount += 1
        return stubbedDomainName
    }

    var invokedPathGetter = false
    var invokedPathGetterCount = 0
    var stubbedPath: String! = ""

    var path: String {
        invokedPathGetter = true
        invokedPathGetterCount += 1
        return stubbedPath
    }

    var invokedHeadersGetter = false
    var invokedHeadersGetterCount = 0
    var stubbedHeaders: [String: String]!

    var headers: [String: String]? {
        invokedHeadersGetter = true
        invokedHeadersGetterCount += 1
        return stubbedHeaders
    }

    var invokedParametersGetter = false
    var invokedParametersGetterCount = 0
    var stubbedParameters: [String: String]!

    var parameters: [String: String]? {
        invokedParametersGetter = true
        invokedParametersGetterCount += 1
        return stubbedParameters
    }

    var invokedRequiresAuthenticationGetter = false
    var invokedRequiresAuthenticationGetterCount = 0
    var stubbedRequiresAuthentication: Bool! = false

    var requiresAuthentication: Bool {
        invokedRequiresAuthenticationGetter = true
        invokedRequiresAuthenticationGetterCount += 1
        return stubbedRequiresAuthentication
    }

    var invokedTimeoutIntervalGetter = false
    var invokedTimeoutIntervalGetterCount = 0
    var stubbedTimeoutInterval: TimeInterval!

    var timeoutInterval: TimeInterval {
        invokedTimeoutIntervalGetter = true
        invokedTimeoutIntervalGetterCount += 1
        return stubbedTimeoutInterval
    }

    var invokedHttpMethodGetter = false
    var invokedHttpMethodGetterCount = 0
    var stubbedHttpMethod: HTTPMethod!

    var httpMethod: HTTPMethod {
        invokedHttpMethodGetter = true
        invokedHttpMethodGetterCount += 1
        return stubbedHttpMethod
    }

    var invokedHttpBodyGetter = false
    var invokedHttpBodyGetterCount = 0
    var stubbedHttpBody: [String: Any]!

    var httpBody: [String: Any]? {
        invokedHttpBodyGetter = true
        invokedHttpBodyGetterCount += 1
        return stubbedHttpBody
    }
}
