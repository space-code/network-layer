//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Atomic
import Foundation
import NetworkLayerInterfaces

// MARK: - DataRequestHandler

final class DataRequestHandler: NSObject {
    // MARK: Properties

    private typealias HandlerDictonary = [URLSessionTask: DataTaskHandler]

    @Atomic private var handlers: HandlerDictonary = [:]
    private var userDataDelegate: URLSessionDataDelegate?

    var urlSessionDelegate: URLSessionDelegate? {
        didSet {
            userDataDelegate = urlSessionDelegate as? URLSessionDataDelegate
        }
    }
}

// MARK: IDataRequestHandler

extension DataRequestHandler: IDataRequestHandler {
    func startDataTask(
        _ task: URLSessionDataTask,
        session _: URLSession,
        delegate: URLSessionDelegate?
    ) async throws -> Response<Data> {
        try await withTaskCancellationHandler(operation: {
            try await withUnsafeThrowingContinuation { continuation in
                let dataTaskHandler = DataTaskHandler(delegate: delegate)
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
    func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let handler = handlers[task] else { return }
        handlers[task] = nil

        if let error = error {
            handler.completion?(.failure(error))
        } else {
            if let response = task.response {
                let data = handler.data ?? Data()
                let response = Response(data: data, response: response)
                handler.completion?(.success(response))
            } else {
                handler.completion?(.failure(URLError(.unknown)))
            }
        }
    }
}

// MARK: DataRequestHandler.DataTaskHandler

private extension DataRequestHandler {
    private class DataTaskHandler {
        // MARK: Types

        typealias Completion = (Result<Response<Data>, Error>) -> Void

        // MARK: Properties

        let delegate: URLSessionDelegate?

        var data: Data?
        var completion: Completion?

        // MARK: Initialization

        init(delegate: URLSessionDelegate?) {
            self.delegate = delegate
        }
    }
}
