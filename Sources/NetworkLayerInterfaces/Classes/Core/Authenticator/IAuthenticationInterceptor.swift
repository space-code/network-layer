//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

/// A type defines the authenticator interceptor interface.
public protocol IAuthenticationInterceptor: Sendable {
    /// Adapts the request with credentials.
    ///
    /// - Parameters:
    ///   - request: The URLRequest to be adapted.
    ///   - session: The URLSession for which the request is being adapted.
    func adapt(request: inout URLRequest, for session: URLSession) async throws

    /// Refreshes credential for the request.
    ///
    /// - Parameters:
    ///   - request: The URLRequest to be refreshed.
    ///   - session: The URLSession for which the request is being refreshed.
    func refresh(_ request: URLRequest, with response: HTTPURLResponse, for session: URLSession) async throws

    /// Determines whether a request requires a credential refresh.
    ///
    /// - Parameters:
    ///   - request: The URLRequest to check.
    ///   - response: The HTTPURLResponse received for the request.
    ///
    /// - Returns: A boolean indicating whether a credential refresh is required.
    func isRequireRefresh(_ request: URLRequest, response: HTTPURLResponse) -> Bool
}
