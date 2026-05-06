//
// network-layer
// Copyright © 2026 Space Code. All rights reserved.
//

@testable import NetworkLayer
import NetworkLayerInterfaces
import Typhoon
import XCTest

// MARK: - RequestProcessorAuthTests

final class RequestProcessorAuthTests: XCTestCase {
    // MARK: Properties

    private var requestBuilderMock: RequestBuilderMock!
    private var dataRequestHandler: DataRequestHandlerMock!
    private var retryPolicyMock: RetryPolicyService!
    private var delegateMock: RequestProcessorDelegateMock!
    private var interceptorMock: AuthentificatorInterceptorMock!

    private var sut: RequestProcessor!

    // MARK: XCTestCase

    override func setUp() {
        super.setUp()
        requestBuilderMock = RequestBuilderMock()
        dataRequestHandler = DataRequestHandlerMock()
        retryPolicyMock = RetryPolicyService(
            strategy: .constant(retry: 0, dispatchDuration: .seconds(.zero))
        )
        delegateMock = RequestProcessorDelegateMock()
        interceptorMock = AuthentificatorInterceptorMock()
        makeSUT()
    }

    override func tearDown() {
        requestBuilderMock = nil
        dataRequestHandler = nil
        retryPolicyMock = nil
        delegateMock = nil
        interceptorMock = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - authenticatedRetryIfNeeded: basic paths

    func test_send_doesNotRetry_whenRefreshIsNotRequired() async throws {
        // given
        requestBuilderMock.stubbedBuildResult = URLRequest.fake()
        interceptorMock.stubbedIsRequireRefreshResult = false
        dataRequestHandler.stubbedStartDataTask = .init(
            data: .data,
            response: HTTPURLResponse.fake(statusCode: 200),
            task: .fake()
        )

        // when
        _ = try await sut.send(authenticatedRequest()) as Response<Int>

        // then
        XCTAssertEqual(dataRequestHandler.invokedStartDataTaskCount, 1)
        XCTAssertFalse(interceptorMock.invokedRefresh)
    }

    func test_send_retriesWithAdaptedRequest_afterSuccessfulRefresh() async {
        // given
        requestBuilderMock.stubbedBuildResult = URLRequest.fake()

        let callCount = Atomic(0)
        interceptorMock.isRequireRefreshClosure = {
            callCount.increment()
            return callCount.value == 1
        }
        dataRequestHandler.stubbedStartDataTask = .init(
            data: .data,
            response: HTTPURLResponse.fake(statusCode: 200),
            task: .fake()
        )

        // when
        _ = try? await sut.send(authenticatedRequest()) as Response<Int>

        // then
        XCTAssertEqual(dataRequestHandler.invokedStartDataTaskCount, 2)
        XCTAssertTrue(interceptorMock.invokedRefresh)
        XCTAssertEqual(interceptorMock.invokedAdaptCount, 2)
    }

    func test_send_throwsMissingCredential_whenRetryResponseStillRequiresRefresh() async throws {
        // given
        requestBuilderMock.stubbedBuildResult = URLRequest.fake()
        interceptorMock.stubbedIsRequireRefreshResult = true
        dataRequestHandler.stubbedStartDataTask = .init(
            data: .data,
            response: HTTPURLResponse.fake(statusCode: 401),
            task: .fake()
        )

        // when
        var thrownError: Error?
        do {
            _ = try await sut.send(authenticatedRequest()) as Response<Int>
        } catch {
            thrownError = error
        }

        // then
        XCTAssertEqual(
            dataRequestHandler.invokedStartDataTaskCount,
            2,
            "Should make exactly 2 calls: original + one retry after refresh"
        )
        XCTAssertEqual(thrownError as? AuthenticatorInterceptorError, .missingCredential)
    }

    func test_send_doesNotTriggerSecondRefresh_whenRetryResponseIsUnauthorised() async {
        // given
        requestBuilderMock.stubbedBuildResult = URLRequest.fake()
        interceptorMock.stubbedIsRequireRefreshResult = true
        dataRequestHandler.stubbedStartDataTask = .init(
            data: .data,
            response: HTTPURLResponse.fake(statusCode: 401),
            task: .fake()
        )

        // when
        _ = try? await sut.send(authenticatedRequest()) as Response<Int>

        // then
        XCTAssertEqual(
            interceptorMock.invokedRefreshCount,
            1,
            "Post-retry status check must not trigger a second refresh"
        )
    }

    func test_concurrentRequests_triggerRefreshOnlyOnce_whenAllDetect401() async throws {
        // given
        requestBuilderMock.stubbedBuildResult = URLRequest.fake()

        let refreshDone = Atomic(false)
        interceptorMock.isRequireRefreshClosure = { !refreshDone.value }
        interceptorMock.refreshClosure = {
            try await Task.sleep(nanoseconds: 50_000_000)
            refreshDone.value = true
        }
        dataRequestHandler.stubbedStartDataTask = .init(
            data: .data,
            response: HTTPURLResponse.fake(statusCode: 200),
            task: .fake()
        )

        let sut = try XCTUnwrap(sut)
        let request = authenticatedRequest()
        let concurrency = 5

        // when
        await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0 ..< concurrency {
                group.addTask {
                    _ = try? await sut.send(request) as Response<Int>
                }
            }
        }

        // then
        XCTAssertEqual(
            interceptorMock.invokedRefreshCount,
            1,
            "Exactly one refresh must occur even when \(concurrency) requests race"
        )
    }

    func test_concurrentRequests_allSucceed_afterSingleRefresh() async throws {
        // given
        requestBuilderMock.stubbedBuildResult = URLRequest.fake()

        let refreshDone = Atomic(false)
        interceptorMock.isRequireRefreshClosure = { !refreshDone.value }
        interceptorMock.refreshClosure = {
            try await Task.sleep(nanoseconds: 30_000_000)
            refreshDone.value = true
        }
        dataRequestHandler.stubbedStartDataTask = .init(
            data: .data,
            response: HTTPURLResponse.fake(statusCode: 200),
            task: .fake()
        )

        let sut = try XCTUnwrap(sut)
        let request = authenticatedRequest()
        let concurrency = 4
        let successCount = Atomic(0)

        // when
        await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0 ..< concurrency {
                group.addTask {
                    _ = try? await sut.send(request) as Response<Int>
                    successCount.increment()
                }
            }
        }

        // then
        XCTAssertEqual(
            successCount.value,
            concurrency,
            "All \(concurrency) concurrent requests should complete successfully"
        )
        XCTAssertEqual(interceptorMock.invokedRefreshCount, 1)
    }

    func test_secondRefreshCycle_startsCleanly_afterFirstCycleCompletes() async {
        // given
        requestBuilderMock.stubbedBuildResult = URLRequest.fake()

        let callCount = Atomic(0)
        interceptorMock.isRequireRefreshClosure = {
            callCount.increment()
            return callCount.value % 2 != 0
        }
        dataRequestHandler.stubbedStartDataTask = .init(
            data: .data,
            response: HTTPURLResponse.fake(statusCode: 200),
            task: .fake()
        )

        let request = authenticatedRequest()

        // when
        _ = try? await sut.send(request) as Response<Int>
        _ = try? await sut.send(request) as Response<Int>

        // then
        XCTAssertEqual(
            interceptorMock.invokedRefreshCount,
            2,
            "Each expired-token detection should produce exactly one refresh"
        )
    }

    func test_pendingRefreshError_propagatesToAllWaitingRequests() async throws {
        // given
        requestBuilderMock.stubbedBuildResult = URLRequest.fake()
        interceptorMock.stubbedIsRequireRefreshResult = true

        let refreshError = URLError(.userAuthenticationRequired)
        interceptorMock.refreshClosure = {
            try await Task.sleep(nanoseconds: 20_000_000)
            throw refreshError
        }
        dataRequestHandler.stubbedStartDataTask = .init(
            data: .data,
            response: HTTPURLResponse.fake(statusCode: 401),
            task: .fake()
        )

        let sut = try XCTUnwrap(sut)
        let request = authenticatedRequest()
        let concurrency = 3
        let errors = Atomic<[Error]>([])

        // when
        await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0 ..< concurrency {
                group.addTask {
                    do {
                        _ = try await sut.send(request) as Response<Int>
                    } catch {
                        errors.append(error)
                    }
                }
            }
        }

        // then
        XCTAssertEqual(interceptorMock.invokedRefreshCount, 1)
        XCTAssertEqual(
            errors.value.count,
            concurrency,
            "All \(concurrency) requests should fail when the shared refresh fails"
        )
    }
}

// MARK: - Helpers

private extension RequestProcessorAuthTests {
    func makeSUT(retryEvaluator: (@Sendable (Error) -> RetryAction)? = { _ in .stop }) {
        sut = RequestProcessor(
            configuration: Configuration(
                sessionConfiguration: .default,
                sessionDelegate: nil,
                sessionDelegateQueue: nil,
                jsonDecoder: JSONDecoder()
            ),
            requestBuilder: requestBuilderMock,
            dataRequestHandler: dataRequestHandler,
            retryPolicyService: retryPolicyMock,
            delegate: SafeRequestProcessorDelegate(delegate: delegateMock),
            interceptor: interceptorMock,
            retryEvaluator: retryEvaluator
        )
    }

    func authenticatedRequest() -> RequestMock {
        let request = RequestMock()
        request.stubbedRequiresAuthentication = true
        return request
    }
}

// MARK: - Atomic

/// A generic thread-safe wrapper backed by `NSLock`.
///
/// Used in tests to share mutable state across concurrent tasks while keeping
/// closures synchronous — no `await` needed at the call site.
private final class Atomic<T>: @unchecked Sendable {
    private var _value: T
    private let lock = NSLock()

    init(_ value: T) {
        _value = value
    }

    var value: T {
        get { lock.withLock { _value } }
        set { lock.withLock { _value = newValue } }
    }
}

private extension Atomic where T == Int {
    func increment() {
        lock.withLock { _value += 1 }
    }
}

private extension Atomic where T == [Error] {
    func append(_ error: Error) {
        lock.withLock { _value.append(error) }
    }
}

// MARK: - Convenience

private extension HTTPURLResponse {
    static func fake(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }
}

private extension Data {
    static let data = "123".data(using: .utf8)!
}
