//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Atomic
import Foundation
import NetworkLayerInterfaces

/// A custom AuthenticatorInterceptor implementation that works with a specific type
/// of Authenticator conforming to the IAuthenticator protocol.
public final class AuthenticatorInterceptor<Authenticator: IAuthenticator>: IAuthenticatorInterceptor {
    // MARK: Types

    public typealias Credential = Authenticator.Credential

    // MARK: Private

    private let authenticator: Authenticator
    @Atomic public var credential: Credential?

    // MARK: Initialization

    public init(authenticator: Authenticator, credential: Credential? = nil) {
        self.authenticator = authenticator
        self.credential = credential
    }

    // MARK: IAuthentificatorInterceptor

    public func adapt(request: URLRequest, for session: URLSession) async throws {
        guard let credential else {
            throw AuthenticatorInterceptorError.missingCredential
        }

        if credential.requiresRefresh {
            try await refresh(credential, for: session)
        } else {
            try await authenticator.apply(credential, to: request)
        }
    }

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

    public func isRequireRefresh(_ request: URLRequest, response: HTTPURLResponse) -> Bool {
        authenticator.didRequest(request, with: response)
    }

    // MARK: Private

    private func refresh(_ credential: Credential, for session: URLSession) async throws {
        let credential = try await authenticator.refresh(credential, for: session)
        self.credential = credential
    }
}