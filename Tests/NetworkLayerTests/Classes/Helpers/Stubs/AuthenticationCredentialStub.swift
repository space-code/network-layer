//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces

final class AuthenticationCredentialStub: IAuthenticationCredential, @unchecked Sendable {
    var stubbedRequiresRefresh: Bool! = false

    var requiresRefresh: Bool {
        stubbedRequiresRefresh
    }
}
