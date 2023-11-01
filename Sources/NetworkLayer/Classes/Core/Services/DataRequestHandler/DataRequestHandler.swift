//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

// MARK: - DataRequestHandler

final class DataRequestHandler: NSObject, IDataRequestHandler {
    // MARK: Properties

    private var handlers: [URLSessionTask: DataTaskHandler] = [:]
    private var userDataDelegate: URLSessionDataDelegate?

    var urlSessionDelegate: URLSessionDelegate? {
        didSet {
            userDataDelegate = urlSessionDelegate as? URLSessionDataDelegate
        }
    }

    private class DataTaskHandler {
        typealias Completion = (Result<Data, Error>) -> Void

        var data: Data?
        var completion: Completion?
    }

    func startDataTask(_ task: URLSessionDataTask, session _: URLSession, delegate _: URLSessionDelegate?) async throws -> Data {
        try await withTaskCancellationHandler(operation: {
            try await withUnsafeThrowingContinuation { continuation in
                let dataTaskHandler = DataTaskHandler()
                dataTaskHandler.completion = continuation.resume(with:)
                handlers[task] = dataTaskHandler
                task.resume()
            }
        }, onCancel: {
            task.cancel()
        })
    }
}

// MARK: URLSessionDataDelegate

extension DataRequestHandler {
    func urlSession(_: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let handler = handlers[dataTask] else { return }

        if handler.data == nil {
            handler.data = Data()
        }
        handler.data?.append(data)
    }
}

// MARK: URLSessionTaskDelegate

extension DataRequestHandler {
    func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError _: Error?) {
        guard let handler = handlers[task] else { return }
        handlers[task] = nil
    }
}
