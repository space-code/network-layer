//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces

final class AuthenticationCredentialStub: IAuthenticationCredential {
    var stubbedRequiresRefresh: Bool! = false

    var requiresRefresh: Bool {
        stubbedRequiresRefresh
    }
}
