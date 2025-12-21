//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import enum Typhoon.RetryPolicyStrategy

// MARK: - INetworkLayerAssembly

/// A protocol defining the blueprint for constructing the network layer's infrastructure.
///
/// Use implementations of this protocol to manage dependencies, configure session settings,
/// and produce a functional `IRequestProcessor`.
public protocol INetworkLayerAssembly {
    /// Initializes a new instance of the assembly with specific components.
    ///
    /// - Parameters:
    ///   - configure: High-level configuration for the network session (decoders, session types, etc.).
    ///   - retryStrategy: The strategy governing if and how failed requests should be retried.
    ///   - delegate: An optional object to monitor or intercept request lifecycle events.
    ///   - interceptor: An optional component for handling authentication logic, such as token injection or refreshing.
    ///   - jsonEncoder: The encoder used for serializing request body parameters into JSON.
    ///   - retryEvaluator: A global evaluator to determine if a retry should be attempted based on the error.
    init(
        configure: Configuration,
        retryStrategy: RetryStrategy,
        delegate: RequestProcessorDelegate?,
        interceptor: IAuthenticationInterceptor?,
        jsonEncoder: JSONEncoder,
        retryEvaluator: (@Sendable (Error) -> Bool)?
    )

    /// Construct and link all internal components to create a request processor.
    ///
    /// This method resolves all dependencies (builders, handlers, strategies) and returns
    /// a ready-to-use engine for executing network calls.
    ///
    /// - Returns: A fully configured instance conforming to `IRequestProcessor`.
    func assemble() -> IRequestProcessor
}

// MARK: - Default Implementation

public extension INetworkLayerAssembly {
    /// Provides a simplified initializer with default values for common components.
    ///
    /// This initializer uses `.none` for retry strategy, no delegate or interceptor,
    /// and a standard `JSONEncoder`.
    ///
    /// - Parameter configure: The network layer's configuration.
    init(configure: Configuration) {
        self.init(
            configure: configure,
            retryStrategy: .none,
            delegate: nil,
            interceptor: nil,
            jsonEncoder: JSONEncoder(),
            retryEvaluator: nil
        )
    }
}
