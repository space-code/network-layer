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
    /// The data request handler.
    private let dataRequestHandler: IDataRequestHandler
    /// The retry policy service.
    private let retryPolicyService: IRetryPolicyService
    /// The request processor delegate.
    private let delegate: RequestProcessorDelegate

    // MARK: Initialization

    public init(
        configure: Configuration,
        requestBuilder: IRequestBuilder,
        dataRequestHandler: IDataRequestHandler,
        retryPolicyService: IRetryPolicyService,
        delegate: RequestProcessorDelegate
    ) {
        self.configure = configure
        self.requestBuilder = requestBuilder
        self.dataRequestHandler = dataRequestHandler
        self.retryPolicyService = retryPolicyService
        self.delegate = delegate
    }

    // MARK: INetworkLayerAssembly

    public func assemble() -> IRequestProcessor {
        RequestProcessor(
            configuration: configure,
            requestBuilder: requestBuilder,
            dataRequestHandler: dataRequestHandler,
            retryPolicyService: retryPolicyService,
            delegate: delegate
        )
    }
}
