//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

/// `AuthenticatorInterceptorError` is the error type returned by AuthenticatorInterceptor.
public enum AuthenticatorInterceptorError: Swift.Error {
    /// The credential was not found.
    case missingCredential
}
