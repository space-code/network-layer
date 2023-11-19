//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

/// A type defines the authenticator interceptor interface.
public protocol IAuthenticatorInterceptor {
    /// Adapts the request with credentials.
    ///
    /// - Parameters:
    ///   - request: The URLRequest to be adapted.
    ///   - session: The URLSession for which the request is being adapted.
    func adapt(request: URLRequest, for session: URLSession) async throws

    /// Refreshes credential for the request.
    ///
    /// - Parameters:
    ///   - request: The URLRequest to be refreshed.
    ///   - session: The URLSession for which the request is being refreshed.
    func refresh(_ request: URLRequest, with response: HTTPURLResponse, for session: URLSession) async throws

    /// <#Description#>
    ///
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - response: <#response description#>
    ///
    /// - Returns: <#description#>
    func isRequireRefresh(_ request: URLRequest, response: HTTPURLResponse) -> Bool
}
