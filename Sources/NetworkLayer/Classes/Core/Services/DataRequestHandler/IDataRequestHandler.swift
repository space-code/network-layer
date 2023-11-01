//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

protocol IDataRequestHandler: URLSessionTaskDelegate & URLSessionDataDelegate {
    func startDataTask(_ task: URLSessionDataTask, session: URLSession, delegate: URLSessionDelegate?) async throws -> Data
}
