//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces

final class RequestStub: IRequest {
    var domainName: String {
        "http://google.com/"
    }

    var path: String {
        "path"
    }

    var headers: [String: String]? {
        [:]
    }

    var parameters: [String: String]? {
        [:]
    }

    var requiresAuthentication: Bool {
        false
    }

    var timeoutInterval: TimeInterval {
        1.0
    }

    var httpMethod: NetworkLayerInterfaces.HTTPMethod {
        .delete
    }

    var httpBody: [String: Any]? {
        nil
    }
}
