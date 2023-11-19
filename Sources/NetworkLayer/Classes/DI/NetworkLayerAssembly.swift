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
    /// The request builder.
    private let requestBuilder: IRequestBuilder
    /// The retry policy service.
    private let retryPolicyStrategy: RetryPolicyStrategy?
    /// The request processor delegate.
    private let delegate: RequestProcessorDelegate?
    /// The authenticator interceptor.
    private let interceptor: IAuthenticatorInterceptor?

    // MARK: Initialization

    public init(
        configure: Configuration,
        requestBuilder: IRequestBuilder,
        retryPolicyStrategy: RetryPolicyStrategy?,
        delegate: RequestProcessorDelegate?,
        interceptor: IAuthenticatorInterceptor?
    ) {
        self.configure = configure
        self.requestBuilder = requestBuilder
        self.retryPolicyStrategy = retryPolicyStrategy
        self.delegate = delegate
        self.interceptor = interceptor
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
}
