//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

struct RequestParametersEncoder: IRequestParametersEncoder {
    func encode(parameters: [String: String], to request: inout URLRequest) throws {
        guard let url = request.url else {
            throw URLError(.badURL)
        }

        if parameters.isEmpty {
            return
        }

        let queries = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        var urlComponents = URLComponents(string: url.absoluteString)

        urlComponents?.queryItems = queries

        guard let url = urlComponents?.url else {
            throw URLError(.badURL)
        }

        request.url = url
    }
}
