//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

public protocol IParameterEncoder {
    func encode<Parameters: Encodable>(
        _ parameters: Parameters?,
        into request: URLRequest
    ) throws -> URLRequest
}
