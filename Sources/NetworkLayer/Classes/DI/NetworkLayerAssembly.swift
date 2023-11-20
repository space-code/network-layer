//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces
import Typhoon

public final class NetworkLayerAssembly: INetworkLayerAssembly {
    // MARK: Properties

    /// The network layer's configuration.
    private let configure: Configuration
    /// The retry policy service.
    private let retryPolicyStrategy: RetryPolicyStrategy?
    /// The request processor delegate.
    private let delegate: RequestProcessorDelegate?
    /// The authenticator interceptor.
    private let interceptor: IAuthenticatorInterceptor?
    /// The json encoder.
    private let jsonEncoder: JSONEncoder

    // MARK: Initialization

    public init(
        configure: Configuration,
        retryPolicyStrategy: RetryPolicyStrategy?,
        delegate: RequestProcessorDelegate?,
        interceptor: IAuthenticatorInterceptor?,
        jsonEncoder: JSONEncoder
    ) {
        self.configure = configure
        self.retryPolicyStrategy = retryPolicyStrategy
        self.delegate = delegate
        self.interceptor = interceptor
        self.jsonEncoder = jsonEncoder
    }

    // MARK: INetworkLayerAssembly

    public func assemble() -> IRequestProcessor {
        RequestProcessor(
            configuration: configure,
            requestBuilder: requestBuilder,
            dataRequestHandler: DataRequestHandler(),
            retryPolicyService: RetryPolicyService(strategy: retryPolicyStrategy ?? defaultStrategy),
            delegate: delegate,
            interceptor: interceptor
        )
    }

    // MARK: Private

    private var defaultStrategy: RetryPolicyStrategy {
        .constant(retry: 5, duration: .seconds(1))
    }

    private var requestBuilder: IRequestBuilder {
        RequestBuilder(
            parametersEncoder: parametersEncoder,
            requestBodyEncoder: requestBodyEncoder
        )
    }

    private var parametersEncoder: IRequestParametersEncoder {
        RequestParametersEncoder()
    }

    private var requestBodyEncoder: IRequestBodyEncoder {
        RequestBodyEncoder(jsonEncoder: jsonEncoder)
    }
}
