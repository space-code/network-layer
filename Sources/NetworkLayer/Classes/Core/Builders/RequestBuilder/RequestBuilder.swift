//
// network-layer
// Copyright © 2024 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces

final class RequestBuilder: IRequestBuilder, @unchecked Sendable {
    // MARK: Properties

    private let parametersEncoder: IRequestParametersEncoder
    private let requestBodyEncoder: IRequestBodyEncoder
    private let queryFormatter: IQueryParametersFormatter

    // MARK: Initialization

    init(
        parametersEncoder: IRequestParametersEncoder,
        requestBodyEncoder: IRequestBodyEncoder,
        queryFormatter: IQueryParametersFormatter
    ) {
        self.parametersEncoder = parametersEncoder
        self.requestBodyEncoder = requestBodyEncoder
        self.queryFormatter = queryFormatter
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

        let parameters = queryFormatter.format(rawParameters: request.parameters ?? [:])
        try parametersEncoder.encode(parameters: parameters, to: &urlRequest)

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
