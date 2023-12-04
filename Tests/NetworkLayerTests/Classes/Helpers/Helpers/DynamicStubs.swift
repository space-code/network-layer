//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import Mocker

final class DynamicStubs {
    static func register(stubs: [StubResponse], prefix: String = "https://github.com", statusCode: Int = 200) {
        for stub in stubs {
            let mock = Mock(
                url: URL(string: [prefix, stub.name].joined(separator: "/"))!,
                dataType: .json,
                statusCode: statusCode,
                data: [
                    stub.httpMethod: try! Data(contentsOf: stub.fileURL),
                ]
            )
            mock.register()
        }
    }
}
