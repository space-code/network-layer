//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

/// A type defines an authentication credential interface.
public protocol IAuthenticationCredential: Sendable {
    /// Determines whether the authentication credential requires a refresh.
    var requiresRefresh: Bool { get }
}
