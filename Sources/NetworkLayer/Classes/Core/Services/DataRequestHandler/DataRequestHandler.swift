//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Atomic
import Foundation
import NetworkLayerInterfaces

// MARK: - DataRequestHandler

/// Manages data request handlers for URLSessionTasks.
final class DataRequestHandler: NSObject {
    // MARK: Properties

    private typealias HandlerDictonary = [URLSessionTask: DataTaskHandler]

    /// The dictonary that stores handlers.
    @Atomic private var handlers: HandlerDictonary = [:]
    /// A protocol that defines methods that URL session instances call on their
    /// delegates to handle task-level events specific to data and upload tasks.
    private var userDataDelegate: URLSessionDataDelegate?

    /// A protocol that defines methods that URL session instances call on their
    /// delegates to handle session-level events, like session life cycle changes.
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

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        userDataDelegate?.urlSession?(session, didBecomeInvalidWithError: error)
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        willCacheResponse proposedResponse: CachedURLResponse,
        completionHandler: @escaping (CachedURLResponse?) -> Void
    ) {
        userDataDelegate?.urlSession?(
            session,
            dataTask: dataTask,
            willCacheResponse: proposedResponse,
            completionHandler: completionHandler
        )
        completionHandler(proposedResponse)
    }
}

// MARK: URLSessionTaskDelegate

extension DataRequestHandler {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let handler = handlers[task] else { return }
        handlers[task] = nil

        userDataDelegate?.urlSession?(session, task: task, didCompleteWithError: error)

        if let error = error {
            handler.completion?(.failure(error))
        } else {
            if let response = task.response {
                let data = handler.data ?? Data()
                let response = Response(data: data, response: response, task: task)
                handler.completion?(.success(response))
            } else {
                handler.completion?(.failure(URLError(.unknown)))
            }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        userDataDelegate?.urlSession?(session, task: task, didFinishCollecting: metrics)
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        userDataDelegate?.urlSession?(
            session,
            task: task,
            willPerformHTTPRedirection: response,
            newRequest: request,
            completionHandler: completionHandler
        )
        completionHandler(request)
    }

    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        userDataDelegate?.urlSession?(session, taskIsWaitingForConnectivity: task)
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        userDataDelegate?.urlSession?(session, didReceive: challenge, completionHandler: completionHandler)
        completionHandler(.performDefaultHandling, nil)
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willBeginDelayedRequest request: URLRequest,
        completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void
    ) {
        userDataDelegate?.urlSession?(session, task: task, willBeginDelayedRequest: request, completionHandler: completionHandler)
        completionHandler(.continueLoading, nil)
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        userDataDelegate?.urlSession?(
            session,
            task: task,
            didSendBodyData: bytesSent,
            totalBytesSent: totalBytesSent,
            totalBytesExpectedToSend: totalBytesExpectedToSend
        )
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
