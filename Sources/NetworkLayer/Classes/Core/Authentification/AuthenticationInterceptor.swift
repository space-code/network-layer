//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Atomic
import Foundation
import NetworkLayerInterfaces

/// A custom AuthenticationInterceptor implementation that works with a specific type
/// of Authenticator conforming to the IAuthenticator protocol.
public final class AuthenticationInterceptor<Authenticator: IAuthenticator>: IAuthenticationInterceptor {
    // MARK: Types

    public typealias Credential = Authenticator.Credential

    // MARK: Private

    private let authenticator: Authenticator
    @Atomic public var credential: Credential?

    // MARK: Initialization

    /// Creates a new instance of `AuthenticationInterceptor`.
    ///
    /// - Parameters:
    ///   - authenticator: The authenticator.
    ///   - credential: The credential.
    public init(authenticator: Authenticator, credential: Credential? = nil) {
        self.authenticator = authenticator
        self.credential = credential
    }

    // MARK: IAuthentificatorInterceptor

    /// Adapts the request with credentials.
    ///
    /// - Parameters:
    ///   - request: The URLRequest to be adapted.
    ///   - session: The URLSession for which the request is being adapted.
    public func adapt(request: inout URLRequest, for session: URLSession) async throws {
        guard let credential else {
            throw AuthenticatorInterceptorError.missingCredential
        }

        if credential.requiresRefresh {
            try await refresh(credential, for: session)
        } else {
            try await authenticator.apply(credential, to: request)
        }
    }

    /// Refreshes credential for the request.
    ///
    /// - Parameters:
    ///   - request: The URLRequest to be refreshed.
    ///   - session: The URLSession for which the request is being refreshed.
    public func refresh(
        _ request: URLRequest,
        with response: HTTPURLResponse,
        for session: URLSession
    ) async throws {
        guard isRequireRefresh(request, response: response) else {
            return
        }

        guard let credential = credential else {
            throw AuthenticatorInterceptorError.missingCredential
        }

        guard authenticator.isRequest(request, authenticatedWith: credential) else {
            return
        }

        try await refresh(credential, for: session)
    }

    /// Determines whether a request requires a credential refresh.
    ///
    /// - Parameters:
    ///   - request: The URLRequest to check.
    ///   - response: The HTTPURLResponse received for the request.
    ///
    /// - Returns: A boolean indicating whether a credential refresh is required.
    public func isRequireRefresh(_ request: URLRequest, response: HTTPURLResponse) -> Bool {
        authenticator.didRequest(request, with: response)
    }

    // MARK: Private

    private func refresh(_ credential: Credential, for session: URLSession) async throws {
        let credential = try await authenticator.refresh(credential, for: session)
        self.credential = credential
    }
}
