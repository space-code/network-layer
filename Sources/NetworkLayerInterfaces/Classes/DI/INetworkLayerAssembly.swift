//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import enum Typhoon.RetryPolicyStrategy

// MARK: - INetworkLayerAssembly

/// A type that represents a network layer assembly.
public protocol INetworkLayerAssembly {
    /// Creates a new `INetworkLayerAssembly` instance.
    ///
    /// - Parameters:
    ///   - configure: The network layer's configuration.
    ///   - requestBuilder: The request builder.
    ///   - retryPolicyStrategy: The retry policy strategy.
    ///   - delegate: The request processor delegate.
    ///   - interceptor: The authenticator interceptor.
    init(
        configure: Configuration,
        requestBuilder: IRequestBuilder,
        retryPolicyStrategy: RetryPolicyStrategy?,
        delegate: RequestProcessorDelegate?,
        interceptor: IAuthenticatorInterceptor?
    )

    /// Assembles a request processor.
    ///
    /// - Returns: A request processor.
    func assemble() -> IRequestProcessor
}

public extension INetworkLayerAssembly {
    init(
        configure: Configuration,
        requestBuilder: IRequestBuilder
    ) {
        self.init(configure: configure, requestBuilder: requestBuilder, retryPolicyStrategy: nil, delegate: nil, interceptor: nil)
    }
}
