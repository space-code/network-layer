//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces

final class RequestBuilder: IRequestBuilder {
    // MARK: Properties

    private let parametersEncoder: IRequestParametersEncoder
    private let requestBodyEncoder: IRequestBodyEncoder

    // MARK: Initialization

    init(
        parametersEncoder: IRequestParametersEncoder,
        requestBodyEncoder: IRequestBodyEncoder
    ) {
        self.parametersEncoder = parametersEncoder
        self.requestBodyEncoder = requestBodyEncoder
    }

    // MARK: IRequestBuilder

    func build(
        _ request: NetworkLayerInterfaces.IRequest,
        _ configure: ((inout URLRequest) throws -> Void)?
    ) throws -> URLRequest? {
        guard let fullPath = request.fullPath, let url = URL(string: fullPath) else {
            throw URLError(.badURL)
        }

        var urlRequest = URLRequest(
            url: url,
            cachePolicy: request.cachePolicy,
            timeoutInterval: request.timeoutInterval
        )

        urlRequest.httpMethod = request.httpMethod.rawValue

        setHeaders(to: &urlRequest, headers: request.headers)

        try parametersEncoder.encode(parameters: request.parameters ?? [:], to: &urlRequest)

        if let httpBody = request.httpBody {
            try requestBodyEncoder.encode(body: httpBody, to: &urlRequest)
        }

        try configure?(&urlRequest)

        return urlRequest
    }

    // MARK: Private

    private func setHeaders(to request: inout URLRequest, headers: [String: String]?) {
        guard let headers else { return }
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
    }
}
