# Authentication

Learn how to implement authentication.

## Overview

The `network-layer` includes an ``AuthenticationInterceptor`` responsible for handling authentication options.

## Access Tokens

``AuthenticationInterceptor`` requires passing an `IAuthenticator` as initialization parameters that contain logic for updating the access token.

A credential object must conform to `IAuthenticationCredential` protocol that indicates whether the credential is valid.

```swift
import NetworkLayerInterfaces

// Defines a credential model
struct Credential: IAuthenticationCredential {
    let expires: Date
    let requiresRefresh: Bool { expires < Date() }
}
```

Define a `Authenticator` object that confrorms to `IAuthenticator` and implement your own logic for validation and refreshing an access token.

```swift
import NetworkLayerInterfaces

struct Authenticator: IAuthenticator {

    /// Applies the `Credential` to the `URLRequest`.
    ///
    /// - Parameters:
    ///   - credential: The `Credential`.
    ///   - urlRequest: The `URLRequest`.
    func apply(_ credential: Credential, to urlRequest: URLRequest) async throws {
        request.addValue("Bearer <token>", forHTTPHeaderField: "Authorization")
    }

    /// Refreshes the `Credential`.
    ///
    /// - Parameters:
    ///   - credential: The `Credential` to refresh.
    ///   - session: The `URLSession` requiring the refresh.
    func refresh(_ credential: Credential, for session: URLSession) async throws -> Credential {
        // Token refresh logic here
    }

    ///  Determines whether the `URLRequest` failed due to an authentication error based on the `HTTPURLResponse`.
    ///
    /// - Parameters:
    ///   - urlRequest: The `URLRequest`.
    ///   - response: The `HTTPURLResponse`.
    ///
    /// - Returns: `true` if the `URLRequest` failed due to an authentication error, `false` otherwise.
    func didRequest(_ urlRequest: URLRequest, with response: HTTPURLResponse) -> Bool {
        response.statusCode == 401
    }

    /// Determines whether the `URLRequest` is authenticated with the `Credential`.
    ///
    /// - Parameters:
    ///   - urlRequest: The `URLRequest`.
    ///   - credential: The `Credential`.
    ///
    /// - Returns: `true` if the `URLRequest` is authenticated with the `Credential`, `false` otherwise.
    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: Credential) -> Bool {
        true
    }
}
```
