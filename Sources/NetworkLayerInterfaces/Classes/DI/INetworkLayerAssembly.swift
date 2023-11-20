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
    ///   - retryPolicyStrategy: The retry policy strategy.
    ///   - delegate: The request processor delegate.
    ///   - interceptor: The authenticator interceptor.
    ///   - jsonEncoder: The json encoder.
    init(
        configure: Configuration,
        retryPolicyStrategy: RetryPolicyStrategy?,
        delegate: RequestProcessorDelegate?,
        interceptor: IAuthenticatorInterceptor?,
        jsonEncoder: JSONEncoder
    )

    /// Assembles a request processor.
    ///
    /// - Returns: A request processor.
    func assemble() -> IRequestProcessor
}

public extension INetworkLayerAssembly {
    init(
        configure: Configuration
    ) {
        self.init(configure: configure, retryPolicyStrategy: nil, delegate: nil, interceptor: nil, jsonEncoder: JSONEncoder())
    }
}
