//
// network-layer
// Copyright © 2025 Space Code. All rights reserved.
//

import enum Typhoon.RetryPolicyStrategy

// MARK: Type

/// Defines the behavior for retrying failed network requests.
public enum RetryStrategy {
    /// No retry attempts will be made.
    case none
    /// Uses the standard system-defined retry policy.
    case `default`
    /// Uses a specific, custom-defined retry policy.
    /// - Parameter strategy: An instance of `RetryPolicyStrategy` defining the custom rules.
    case custom(RetryPolicyStrategy)
}
