//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

/// <#Description#>
public protocol IAuthenticator {
    associatedtype Credential: IAuthenticationCredential

    /// Applies the `Credential` to the `URLRequest`.
    ///
    /// - Parameters:
    ///   - credential: The `Credential`.
    ///   - urlRequest: The `URLRequest`.
    func apply(_ credential: Credential, to urlRequest: inout URLRequest) async throws

    /// Refreshes the `Credential`.
    ///
    /// - Parameters:
    ///   - credential: The `Credential` to refresh.
    ///   - session: The `URLSession` requiring the refresh.
    func refresh(_ credential: Credential, for session: URLSession) async throws -> Credential

    ///  Determines whether the `URLRequest` failed due to an authentication error based on the `HTTPURLResponse`.
    ///
    /// - Parameters:
    ///   - urlRequest: The `URLRequest`.
    ///   - response: The `HTTPURLResponse`.
    ///   - error: The `Error`.
    ///
    /// - Returns: `true` if the `URLRequest` failed due to an authentication error, `false` otherwise.
    func didRequest(_ urlRequest: URLRequest, with response: HTTPURLResponse, failDueToAuthenticationError error: Error) -> Bool

    /// Determines whether the `URLRequest` is authenticated with the `Credential`.
    ///
    /// - Parameters:
    ///   - urlRequest: The `URLRequest`.
    ///   - credential: The `Credential`.
    ///
    /// - Returns: `true` if the `URLRequest` is authenticated with the `Credential`, `false` otherwise.
    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: Credential) -> Bool
}
