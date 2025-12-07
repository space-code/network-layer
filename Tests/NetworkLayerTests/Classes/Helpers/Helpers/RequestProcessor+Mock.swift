//
// network-layer
// Copyright © 2024 Space Code. All rights reserved.
//

import Foundation
import Mocker
@testable import NetworkLayer
import NetworkLayerInterfaces
import Typhoon

extension RequestProcessor {
    static func mock(
        requestProcessorDelegate: RequestProcessorDelegate? = nil,
        interceptor: IAuthenticationInterceptor? = nil
    ) -> RequestProcessor {
        RequestProcessor(
            configuration: .init(
                sessionConfiguration: sessionConfiguration,
                sessionDelegate: nil,
                sessionDelegateQueue: nil,
                jsonDecoder: jsonDecoder
            ),
            requestBuilder: RequestBuilder(
                parametersEncoder: RequestParametersEncoder(),
                requestBodyEncoder: RequestBodyEncoder(jsonEncoder: JSONEncoder()),
                queryFormatter: QueryParametersFormatter()
            ),
            dataRequestHandler: DataRequestHandler(),
            retryPolicyService: RetryPolicyService(strategy: .constant(retry: 1, duration: .seconds(0))),
            delegate: SafeRequestProcessorDelegate(delegate: requestProcessorDelegate),
            interceptor: interceptor
        )
    }

    private static var sessionConfiguration: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockingURLProtocol.self]
        return configuration
    }

    private static var jsonDecoder: JSONDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }
}
