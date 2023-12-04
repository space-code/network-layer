//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces

struct RequestBodyEncoder: IRequestBodyEncoder {
    // MARK: Properties

    private let jsonEncoder: JSONEncoder

    // MARK: Initialization

    init(jsonEncoder: JSONEncoder) {
        self.jsonEncoder = jsonEncoder
    }

    // MARK: IRequestBodyEncoder

    func encode(body: NetworkLayerInterfaces.RequestBody, to request: inout URLRequest) throws {
        switch body {
        case let .data(data):
            request.httpBody = data
        case let .encodable(encodable):
            request.httpBody = try jsonEncoder.encode(encodable)
        case let .dictonary(dictionary):
            request.httpBody = try JSONSerialization.data(withJSONObject: dictionary)
        }
    }
}
