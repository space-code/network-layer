//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces
import Typhoon

/// A final class responsible for assembling the network layer components.
/// It configures the `IRequestProcessor` with necessary dependencies such as retry policies, interceptors, and encoders.
public final class NetworkLayerAssembly: INetworkLayerAssembly {
    // MARK: Properties

    /// The configuration settings for the network session and decoding.
    private let configure: Configuration
    /// The specific strategy used to handle request retries.
    private let retryPolicyStrategy: RetryPolicyStrategy?
    /// A thread-safe wrapper for the request processor delegate.
    private var delegate: SafeRequestProcessorDelegate?
    /// An optional interceptor for handling authentication (e.g., adding tokens).
    private let interceptor: IAuthenticationInterceptor?
    /// The encoder used to transform objects into JSON data for request bodies.
    private let jsonEncoder: JSONEncoder
    /// A global evaluator to determine if a retry should be attempted based on the error.
    /// This applies to all requests processed by this instance.
    private let retryEvaluator: (@Sendable (Error) -> Bool)?

    // MARK: Initialization

    /// Initializes a new instance of the assembly.
    /// - Parameters:
    ///   - configure: The network configuration. Defaults to a standard session setup.
    ///   - retryStrategy: The strategy to determine how retries are handled. Defaults to `.none`.
    ///   - delegate: An optional delegate to observe request lifecycle events.
    ///   - interceptor: An optional interceptor for request/response modification.
    ///   - jsonEncoder: The encoder used for request bodies.
    ///   - retryEvaluator: A global evaluator to determine if a retry should be attempted based on the error.
    public init(
        configure: Configuration = .init(
            sessionConfiguration: .default,
            sessionDelegate: nil,
            sessionDelegateQueue: nil,
            jsonDecoder: JSONDecoder()
        ),
        retryStrategy: RetryStrategy = .none,
        delegate: RequestProcessorDelegate? = nil,
        interceptor: IAuthenticationInterceptor? = nil,
        jsonEncoder: JSONEncoder = JSONEncoder(),
        retryEvaluator: (@Sendable (Error) -> Bool)? = nil
    ) {
        self.configure = configure
        self.delegate = SafeRequestProcessorDelegate(delegate: delegate)
        self.interceptor = interceptor
        self.jsonEncoder = jsonEncoder
        self.retryEvaluator = retryEvaluator

        switch retryStrategy {
        case .none:
            retryPolicyStrategy = nil
        case .default:
            retryPolicyStrategy = .constant(retry: 5, duration: .seconds(1))
        case let .custom(strategy):
            retryPolicyStrategy = strategy
        }
    }

    // MARK: INetworkLayerAssembly

    /// Assembles and returns a fully configured request processor.
    /// - Returns: An object conforming to `IRequestProcessor` ready to handle network calls.
    public func assemble() -> IRequestProcessor {
        RequestProcessor(
            configuration: configure,
            requestBuilder: requestBuilder,
            dataRequestHandler: DataRequestHandler(),
            retryPolicyService: retryPolicyStrategy.map { RetryPolicyService(strategy: $0) },
            delegate: delegate,
            interceptor: interceptor,
            retryEvaluator: retryEvaluator
        )
    }

    // MARK: - Private Computed Properties

    /// Creates a request builder with the necessary encoders and formatters.
    private var requestBuilder: IRequestBuilder {
        RequestBuilder(
            parametersEncoder: parametersEncoder,
            requestBodyEncoder: requestBodyEncoder,
            queryFormatter: queryFormatter
        )
    }

    /// Provides the encoder for general request parameters.
    private var parametersEncoder: IRequestParametersEncoder {
        RequestParametersEncoder()
    }

    /// Provides the encoder for the request body, utilizing the assembly's JSON encoder.
    private var requestBodyEncoder: IRequestBodyEncoder {
        RequestBodyEncoder(jsonEncoder: jsonEncoder)
    }

    /// Provides the formatter for URL query parameters.
    private var queryFormatter: IQueryParametersFormatter {
        QueryParametersFormatter()
    }
}
