//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces

final class RequestStub: IRequest, @unchecked Sendable {
    var stubbedDomainName: String! = ""

    var domainName: String {
        stubbedDomainName
    }

    var stubbedPath: String! = ""

    var path: String {
        stubbedPath
    }

    var stubbedHeaders: [String: String]!

    var headers: [String: String]? {
        stubbedHeaders
    }

    var stubbedParameters: [String: String]!

    var parameters: [String: String]? {
        stubbedParameters
    }

    var stubbedRequiresAuthentication: Bool! = false

    var requiresAuthentication: Bool {
        stubbedRequiresAuthentication
    }

    var stubbedTimeoutInterval: TimeInterval = 60

    var timeoutInterval: TimeInterval {
        stubbedTimeoutInterval
    }

    var stubbedHttpMethod: HTTPMethod = .get

    var httpMethod: HTTPMethod {
        stubbedHttpMethod
    }

    var stubbedHttpBody: RequestBody?

    var httpBody: RequestBody? {
        stubbedHttpBody
    }

    var stubbedCachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy

    var cachePolicy: URLRequest.CachePolicy {
        stubbedCachePolicy
    }
}
