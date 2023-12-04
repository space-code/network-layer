//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

/// A type that represents a configuration for the network layer.
public struct Configuration {
    // MARK: Properties

    /// A configuration object that defines behavior and policies for a URL session.
    public let sessionConfiguration: URLSessionConfiguration
    /// A protocol that defines methods that URL session instances call on their delegates
    /// to handle session-level events, like session life cycle changes.
    public let sessionDelegate: URLSessionDelegate?
    /// A queue that regulates the execution of operations.
    public let sessionDelegateQueue: OperationQueue?
    /// An object that decodes instances of a data type from JSON objects.
    public let jsonDecoder: JSONDecoder

    // MARK: Initialization

    /// Creates a new `Configuration` instance.
    ///
    /// - Parameters:
    ///   - sessionConfiguration: A configuration object that defines behavior and policies for a URL session.
    ///   - sessionDelegate: A protocol that defines methods that URL session instances call on their
    ///                      delegates to handle session-level events, like session life cycle changes.
    ///   - sessionDelegateQueue: A queue that regulates the execution of operations.
    ///   - jsonDecoder: An object that decodes instances of a data type from JSON objects.
    public init(
        sessionConfiguration: URLSessionConfiguration,
        sessionDelegate: URLSessionDelegate?,
        sessionDelegateQueue: OperationQueue?,
        jsonDecoder: JSONDecoder
    ) {
        self.sessionConfiguration = sessionConfiguration
        self.sessionDelegate = sessionDelegate
        self.sessionDelegateQueue = sessionDelegateQueue
        self.jsonDecoder = jsonDecoder
    }
}
