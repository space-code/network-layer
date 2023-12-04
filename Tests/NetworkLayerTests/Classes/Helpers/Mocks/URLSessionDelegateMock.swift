//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation

final class URLSessionDelegateMock: NSObject, URLSessionDataDelegate {
    var invokedUrlSessionDidBecomeInvalidWithError = false
    var invokedUrlSessionDidBecomeInvalidWithErrorCount = 0
    var invokedUrlSessionDidBecomeInvalidWithErrorParameters: (session: URLSession, error: Error?)?
    var invokedUrlSessionDidBecomeInvalidWithErrorParametersList = [(session: URLSession, error: Error?)]()

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        invokedUrlSessionDidBecomeInvalidWithError = true
        invokedUrlSessionDidBecomeInvalidWithErrorCount += 1
        invokedUrlSessionDidBecomeInvalidWithErrorParameters = (session, error)
        invokedUrlSessionDidBecomeInvalidWithErrorParametersList.append((session, error))
    }

    var invokedUrlSessionWillCacheResponse = false
    var invokedUrlSessionWillCacheResponseCount = 0
    var invokedUrlSessionWillCacheResponseParameters: (
        session: URLSession,
        dataTask: URLSessionDataTask,
        proposedResponse: CachedURLResponse,
        completionHandler: (CachedURLResponse?) -> Void
    )?
    var invokedUrlSessionWillCacheResponseParametersList = [(
        session: URLSession,
        dataTask: URLSessionDataTask,
        proposedResponse: CachedURLResponse,
        completionHandler: (CachedURLResponse?) -> Void
    )]()
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        willCacheResponse proposedResponse: CachedURLResponse,
        completionHandler: @escaping (CachedURLResponse?) -> Void
    ) {
        invokedUrlSessionWillCacheResponse = true
        invokedUrlSessionWillCacheResponseCount += 1
        invokedUrlSessionWillCacheResponseParameters = (session, dataTask, proposedResponse, completionHandler)
        invokedUrlSessionWillCacheResponseParametersList.append((session, dataTask, proposedResponse, completionHandler))
    }

    var invokedUrlSessionDidFinishCollectingMetrics = false
    var invokedUrlSessionDidFinishCollectingMetricsCount = 0
    var invokedUrlSessionDidFinishCollectingMetricsParameters: (session: URLSession, task: URLSessionTask, metrics: URLSessionTaskMetrics)?
    var invokedUrlSessionDidFinishCollectingMetricsParametersList = [(
        session: URLSession,
        task: URLSessionTask,
        metrics: URLSessionTaskMetrics
    )]()
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        invokedUrlSessionDidFinishCollectingMetrics = true
        invokedUrlSessionDidFinishCollectingMetricsCount += 1
        invokedUrlSessionDidFinishCollectingMetricsParameters = (session, task, metrics)
        invokedUrlSessionDidFinishCollectingMetricsParametersList.append((session, task, metrics))
    }

    var invokedUrlSessionWillPerformHTTPRedirection = false
    var invokedUrlSessionWillPerformHTTPRedirectionCount = 0
    var invokedUrlSessionWillPerformHTTPRedirectionParameters: (
        session: URLSession,
        task: URLSessionTask,
        response: HTTPURLResponse,
        request: URLRequest,
        completionHandler: (URLRequest?) -> Void
    )?
    var invokedUrlSessionWillPerformHTTPRedirectionParametersList = [(
        session: URLSession,
        task: URLSessionTask,
        response: HTTPURLResponse,
        request: URLRequest,
        completionHandler: (URLRequest?) -> Void
    )]()
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        invokedUrlSessionWillPerformHTTPRedirection = true
        invokedUrlSessionWillPerformHTTPRedirectionCount += 1
        invokedUrlSessionWillPerformHTTPRedirectionParameters = (session, task, response, request, completionHandler)
        invokedUrlSessionWillPerformHTTPRedirectionParametersList = [(session, task, response, request, completionHandler)]
    }

    var invokedUrlSessionTaskIsWaitingForConnectivity = false
    var invokedUrlSessionTaskIsWaitingForConnectivityCount = 0
    var invokedUrlSessionTaskIsWaitingForConnectivityParameters: (session: URLSession, task: URLSessionTask)?
    var invokedUrlSessionTaskIsWaitingForConnectivityParametersList = [(session: URLSession, task: URLSessionTask)]()
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        invokedUrlSessionTaskIsWaitingForConnectivity = true
        invokedUrlSessionTaskIsWaitingForConnectivityCount += 1
        invokedUrlSessionTaskIsWaitingForConnectivityParameters = (session, task)
        invokedUrlSessionTaskIsWaitingForConnectivityParametersList.append((session, task))
    }

    var invokedUrlSessionDidReceiveChallenge = false
    var invokedUrlSessionDidReceiveChallengeCount = 0
    var invokedUrlSessionDidReceiveChallengeParamters: (
        session: URLSession,
        challenge: URLAuthenticationChallenge,
        completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    )?
    var invokedUrlSessionDidReceiveChallengeParamtersList = [(
        session: URLSession,
        challenge: URLAuthenticationChallenge,
        completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    )]()
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        invokedUrlSessionDidReceiveChallenge = true
        invokedUrlSessionDidReceiveChallengeCount += 1
        invokedUrlSessionDidReceiveChallengeParamters = (session, challenge, completionHandler)
        invokedUrlSessionDidReceiveChallengeParamtersList.append((session, challenge, completionHandler))
    }

    var invokedUrlSessionWillBeginDelayedRequest = false
    var invokedUrlSessionWillBeginDelayedRequestCount = 0
    var invokedUrlSessionWillBeginDelayedRequestParameters: (
        session: URLSession,
        task: URLSessionTask,
        request: URLRequest,
        completionHandler: (URLSession.DelayedRequestDisposition, URLRequest?) -> Void
    )?
    var invokedUrlSessionWillBeginDelayedRequestParametersList = [(
        session: URLSession,
        task: URLSessionTask,
        request: URLRequest,
        completionHandler: (URLSession.DelayedRequestDisposition, URLRequest?) -> Void
    )]()
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willBeginDelayedRequest request: URLRequest,
        completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void
    ) {
        invokedUrlSessionWillBeginDelayedRequest = true
        invokedUrlSessionWillBeginDelayedRequestCount += 1
        invokedUrlSessionWillBeginDelayedRequestParameters = (session, task, request, completionHandler)
        invokedUrlSessionWillBeginDelayedRequestParametersList.append((session, task, request, completionHandler))
    }

    var invokedUrlSessionDidSendBodyData = false
    var invokedUrlSessionDidSendBodyDataCount = 0
    var invokedUrlSessionDidSendBodyDataParameters: (
        session: URLSession,
        task: URLSessionTask,
        bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    )?
    var invokedUrlSessionDidSendBodyDataParametersList = [
        (
            session: URLSession,
            task: URLSessionTask,
            bytesSent: Int64,
            totalBytesSent: Int64,
            totalBytesExpectedToSend: Int64
        )
    ]()
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        invokedUrlSessionDidSendBodyData = true
        invokedUrlSessionDidSendBodyDataCount += 1
        invokedUrlSessionDidSendBodyDataParameters = (session, task, bytesSent, totalBytesSent, totalBytesExpectedToSend)
        invokedUrlSessionDidSendBodyDataParametersList = [(session, task, bytesSent, totalBytesSent, totalBytesExpectedToSend)]
    }

    var invokedUrlSessionDidCompleteTaskWithError = false
    var invokedUrlSessionDidCompleteTaskWithErrorCount = 0
    var invokedUrlSessionDidCompleteTaskWithErrorParameters: (session: URLSession, task: URLSessionTask, error: Error?)?
    var invokedUrlSessionDidCompleteTaskWithErrorParametersList = [(session: URLSession, task: URLSessionTask, error: Error?)]()
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        invokedUrlSessionDidCompleteTaskWithError = true
        invokedUrlSessionDidCompleteTaskWithErrorCount += 1
        invokedUrlSessionDidCompleteTaskWithErrorParameters = (session, task, error)
        invokedUrlSessionDidCompleteTaskWithErrorParametersList.append((session, task, error))
    }
}
