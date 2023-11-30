//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

@testable import NetworkLayer
import XCTest

final class DataRequestHanderTests: XCTestCase {
    // MARK: Properties

    private var delegateMock: URLSessionDelegateMock!

    private var sut: DataRequestHandler!

    // MARK: XCTestCase

    override func setUp() {
        super.setUp()
        delegateMock = URLSessionDelegateMock()
        sut = DataRequestHandler()
        sut.urlSessionDelegate = delegateMock
    }

    override func tearDown() {
        delegateMock = nil
        sut = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_thatDataRequestHandlerTriggersDelegate_whenSessionDidBecomeInvalidWithError() {
        // given
        let errorMock = URLError(.unknown)

        // when
        sut.urlSession(.shared, didBecomeInvalidWithError: errorMock)

        // then
        XCTAssertTrue(delegateMock.invokedUrlSessionDidBecomeInvalidWithError)
        XCTAssertEqual(delegateMock.invokedUrlSessionDidBecomeInvalidWithErrorParameters?.error as? URLError, errorMock)
    }

    func test_thatDataRequestHandlerTriggersDelegate_whenSessionWillCacheResponseWithCompletionHandler() {
        // when
        sut.urlSession(
            .shared,
            dataTask: .fake(),
            willCacheResponse: .init(),
            completionHandler: { _ in }
        )

        // then
        XCTAssertTrue(delegateMock.invokedUrlSessionWillCacheResponse)
    }

    func test_thatDataRequestHandlerTriggersDelegate_whenSessionDidFinishCollectingMetrics() {
        // when
        sut.urlSession(.shared, task: .fake(), didFinishCollecting: .init())

        // then
        XCTAssertTrue(delegateMock.invokedUrlSessionDidFinishCollectingMetrics)
    }

    func test_thatDataRequestHandlerTriggersDelegate_whenSessionWillPerformHTTPRedirection() {
        // when
        sut.urlSession(.shared, task: .fake(), willPerformHTTPRedirection: .fake(), newRequest: .fake(), completionHandler: { _ in })

        // then
        XCTAssertTrue(delegateMock.invokedUrlSessionWillPerformHTTPRedirection)
    }

    func test_thatDataRequestHandlerTriggersDelegate_whenSessionTaskIsWaitingForConnectivity() {
        // when
        sut.urlSession(.shared, taskIsWaitingForConnectivity: .fake())

        // then
        XCTAssertTrue(delegateMock.invokedUrlSessionTaskIsWaitingForConnectivity)
    }

    func test_thatDataRequestHandlerTriggersDelegate_whenSessionDidReceiveChallenge() {
        // when
        sut.urlSession(.shared, didReceive: .init(), completionHandler: { _, _ in })

        // then
        XCTAssertTrue(delegateMock.invokedUrlSessionDidReceiveChallenge)
    }

    func test_thatDataRequestHandlerTriggersDelegate_whenSessionWillBeginDelayedRequest() {
        // when
        sut.urlSession(.shared, task: .fake(), willBeginDelayedRequest: .fake(), completionHandler: { _, _ in })

        // then
        XCTAssertTrue(delegateMock.invokedUrlSessionWillBeginDelayedRequest)
    }

    func test_thatDataRequestHandlerTriggersDelegate_whenSessionDidSendBodyData() {
        // when
        sut.urlSession(.shared, task: .fake(), didSendBodyData: .zero, totalBytesSent: .zero, totalBytesExpectedToSend: .zero)

        // then
        XCTAssertTrue(delegateMock.invokedUrlSessionDidSendBodyData)
    }
}
