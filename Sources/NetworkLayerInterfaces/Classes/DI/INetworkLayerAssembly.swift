//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import protocol Typhoon.IRetryPolicyService

/// A type that represents a network layer assembly.
public protocol INetworkLayerAssembly {
    /// Creates a new `INetworkLayerAssembly` instance.
    ///
    /// - Parameters:
    ///   - configure: The network layer's configuration.
    ///   - requestBuilder: The request builder.
    ///   - dataRequestHandler: The data request handler.
    ///   - retryPolicyService: The retry policy service.
    ///   - delegate: The request processor delegate.
    init(
        configure: Configuration,
        requestBuilder: IRequestBuilder,
        dataRequestHandler: IDataRequestHandler,
        retryPolicyService: IRetryPolicyService,
        delegate: RequestProcessorDelegate
    )

    /// Assembles a request processor.
    ///
    /// - Returns: A request processor.
    func assemble() -> IRequestProcessor
}
