//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

@testable import NetworkLayer
import NetworkLayerInterfaces
import Typhoon
import XCTest

// MARK: - RequestProcessorTests

final class RequestProcessorTests: XCTestCase {
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
            strategy: .constant(
                retry: 5,
                duration: .seconds(.zero)
            )
        )
        delegateMock = RequestProcessorDelegateMock()
        interceptorMock = AuthentificatorInterceptorMock()
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
            retryEvaluator: { _ in true }
        )
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

    // MARK: Authentication Tests

    func test_send_appliesAuthenticationInterceptor_whenRequestRequiresAuthentication() async {
        // given
        requestBuilderMock.stubbedBuildResult = URLRequest.fake()
        dataRequestHandler.stubbedStartDataTask = .init(data: Data(), response: .init(), task: .fake())

        let request = RequestMock()
        request.stubbedRequiresAuthentication = true

        // when
        do {
            _ = try await sut.send(request) as Response<Int>
        } catch {}

        // then
        XCTAssertTrue(interceptorMock.invokedAdapt)
        XCTAssertFalse(interceptorMock.invokedRefresh)
    }

    func test_send_skipsAuthenticationInterceptor_whenRequestDoesNotRequireAuthentication() async {
        // given
        requestBuilderMock.stubbedBuildResult = URLRequest.fake()
        dataRequestHandler.stubbedStartDataTask = .init(data: Data(), response: .init(), task: .fake())

        let request = RequestMock()
        request.stubbedRequiresAuthentication = false

        // when
        do {
            _ = try await sut.send(request) as Response<Int>
        } catch {}

        // then
        XCTAssertFalse(interceptorMock.invokedAdapt)
        XCTAssertFalse(interceptorMock.invokedRefresh)
    }

    func test_send_refreshesCredential_whenAuthenticationIsRequiredAndCredentialIsInvalid() async {
        // given
        requestBuilderMock.stubbedBuildResult = URLRequest.fake()
        dataRequestHandler.stubbedStartDataTask = .init(data: Data(), response: HTTPURLResponse(), task: .fake())
        interceptorMock.stubbedIsRequireRefreshResult = true

        let request = RequestMock()
        request.stubbedRequiresAuthentication = true

        // when
        do {
            _ = try await sut.send(request) as Response<Int>
        } catch {}

        // then
        XCTAssertTrue(interceptorMock.invokedAdapt)
        XCTAssertTrue(interceptorMock.invokedRefresh)
    }

    func test_send_skipsCredentialRefresh_whenRequestDoesNotRequireAuthentication() async {
        // given
        requestBuilderMock.stubbedBuildResult = URLRequest.fake()
        dataRequestHandler.startDataTaskThrowError = URLError(.unknown)

        let request = RequestMock()
        request.stubbedRequiresAuthentication = false

        // when
        do {
            _ = try await sut.send(request) as Response<Int>
        } catch {}

        // then
        XCTAssertFalse(interceptorMock.invokedAdapt)
        XCTAssertFalse(interceptorMock.invokedRefresh)
    }

    // MARK: Retry Policy Tests

    func test_send_retriesRequest_whenRequestFailsAndRetryPolicyIsConfigured() async {
        // given
        requestBuilderMock.stubbedBuildResult = URLRequest.fake()
        dataRequestHandler.startDataTaskThrowError = URLError(.networkConnectionLost)

        let request = RequestMock()
        request.stubbedRequiresAuthentication = false

        // when
        do {
            _ = try await sut.send(request) as Response<Int>
        } catch {}

        // then
        XCTAssertGreaterThan(
            dataRequestHandler.invokedStartDataTaskCount,
            1,
            "Request should have been retried multiple times"
        )
    }

    func test_send_doesNotRetry_whenRetryPolicyIsNotConfigured() async {
        // given
        sut = RequestProcessor(
            configuration: Configuration(
                sessionConfiguration: .default,
                sessionDelegate: nil,
                sessionDelegateQueue: nil,
                jsonDecoder: JSONDecoder()
            ),
            requestBuilder: requestBuilderMock,
            dataRequestHandler: dataRequestHandler,
            retryPolicyService: nil,
            delegate: SafeRequestProcessorDelegate(delegate: delegateMock),
            interceptor: interceptorMock,
            retryEvaluator: { _ in true }
        )

        requestBuilderMock.stubbedBuildResult = URLRequest.fake()
        dataRequestHandler.startDataTaskThrowError = URLError(.networkConnectionLost)

        let request = RequestMock()
        request.stubbedRequiresAuthentication = false

        // when
        do {
            _ = try await sut.send(request) as Response<Int>
        } catch {}

        // then
        XCTAssertEqual(
            dataRequestHandler.invokedStartDataTaskCount,
            1,
            "Request should not have been retried without retry policy"
        )
    }

    func test_send_stopsRetrying_whenGlobalRetryEvaluatorReturnsFalse() async {
        // given
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
            retryEvaluator: { _ in false }
        )

        requestBuilderMock.stubbedBuildResult = URLRequest.fake()
        dataRequestHandler.startDataTaskThrowError = URLError(.networkConnectionLost)

        let request = RequestMock()
        request.stubbedRequiresAuthentication = false

        // when
        do {
            _ = try await sut.send(request) as Response<Int>
        } catch {}

        // then
        XCTAssertEqual(
            dataRequestHandler.invokedStartDataTaskCount,
            1,
            "Request should not be retried when global evaluator returns false"
        )
    }

    func test_send_stopsRetrying_whenLocalRetryEvaluatorReturnsFalse() async {
        // given
        requestBuilderMock.stubbedBuildResult = URLRequest.fake()
        dataRequestHandler.startDataTaskThrowError = URLError(.networkConnectionLost)

        let request = RequestMock()
        request.stubbedRequiresAuthentication = false

        // when
        do {
            _ = try await sut.send(
                request,
                shouldRetry: { _ in false }
            ) as Response<Int>
        } catch {}

        // then
        XCTAssertEqual(
            dataRequestHandler.invokedStartDataTaskCount,
            1,
            "Request should not be retried when local evaluator returns false"
        )
    }

    func test_send_retriesRequest_whenBothEvaluatorsReturnTrue() async {
        // given
        requestBuilderMock.stubbedBuildResult = URLRequest.fake()
        dataRequestHandler.startDataTaskThrowError = URLError(.networkConnectionLost)

        let request = RequestMock()
        request.stubbedRequiresAuthentication = false

        // when
        do {
            _ = try await sut.send(
                request,
                shouldRetry: { _ in true }
            ) as Response<Int>
        } catch {}

        // then
        XCTAssertGreaterThan(
            dataRequestHandler.invokedStartDataTaskCount,
            1,
            "Request should be retried when both evaluators return true"
        )
    }

    func test_send_retriesWithCustomStrategy_whenStrategyIsProvided() async {
        // given
        let customRetryCount = 3
        let customStrategy = RetryPolicyStrategy.constant(retry: customRetryCount, duration: .seconds(.zero))

        requestBuilderMock.stubbedBuildResult = URLRequest.fake()
        dataRequestHandler.startDataTaskThrowError = URLError(.networkConnectionLost)

        let request = RequestMock()
        request.stubbedRequiresAuthentication = false

        // when
        do {
            _ = try await sut.send(
                request,
                strategy: customStrategy
            ) as Response<Int>
        } catch {}

        // then
        XCTAssertGreaterThan(
            dataRequestHandler.invokedStartDataTaskCount,
            1,
            "Request should be retried with custom strategy"
        )
        XCTAssertLessThanOrEqual(
            dataRequestHandler.invokedStartDataTaskCount,
            customRetryCount + 1,
            "Should not exceed custom retry count plus initial attempt"
        )
    }

    func test_send_throwsError_whenAllRetriesExhausted() async {
        // given
        requestBuilderMock.stubbedBuildResult = URLRequest.fake()
        dataRequestHandler.startDataTaskThrowError = URLError(.networkConnectionLost)

        let request = RequestMock()
        request.stubbedRequiresAuthentication = false

        // when
        var thrownError: Error?
        do {
            _ = try await sut.send(request) as Response<Int>
        } catch {
            thrownError = error
        }

        // then
        XCTAssertNotNil(thrownError, "Should throw error when all retries are exhausted")
        XCTAssertGreaterThan(
            dataRequestHandler.invokedStartDataTaskCount,
            1,
            "Should have attempted retries before throwing error"
        )
    }

    func test_send_invokesRequestBuilderOnce_whenRequestSucceedsOnFirstAttempt() async {
        // given
        requestBuilderMock.stubbedBuildResult = URLRequest.fake()
        dataRequestHandler.stubbedStartDataTask = .init(data: Data(), response: HTTPURLResponse(), task: .fake())

        let request = RequestMock()
        request.stubbedRequiresAuthentication = false

        // when
        do {
            _ = try await sut.send(request) as Response<Int>
        } catch {}

        // then
        XCTAssertEqual(
            dataRequestHandler.invokedStartDataTaskCount,
            1,
            "Should only attempt request once when successful"
        )
    }

    func test_send_retainsRequestParameters_acrossRetryAttempts() async {
        // given
        requestBuilderMock.stubbedBuildResult = URLRequest.fake()
        dataRequestHandler.startDataTaskThrowError = URLError(.networkConnectionLost)

        let request = RequestMock()
        request.stubbedRequiresAuthentication = false

        // when
        do {
            _ = try await sut.send(request) as Response<Int>
        } catch {}

        // then
        XCTAssertGreaterThan(
            dataRequestHandler.invokedStartDataTaskParametersList.count,
            1,
            "Should have multiple retry attempts recorded"
        )

        let firstDelegate = dataRequestHandler.invokedStartDataTaskParametersList.first?.delegate
        let lastDelegate = dataRequestHandler.invokedStartDataTaskParametersList.last?.delegate
        XCTAssertTrue(
            (firstDelegate == nil && lastDelegate == nil) || (firstDelegate != nil && lastDelegate != nil),
            "Delegate should be consistent across retries"
        )
    }

    func test_send_evaluatesErrorType_beforeRetrying() async {
        // given
        let errorBox = Box<Error>()
        requestBuilderMock.stubbedBuildResult = URLRequest.fake()
        let specificError = URLError(.networkConnectionLost)
        dataRequestHandler.startDataTaskThrowError = specificError

        // when
        do {
            _ = try await sut.send(
                RequestMock(),
                shouldRetry: { error in
                    errorBox.value = error
                    return false
                }
            ) as Response<Int>
        } catch {}

        // then
        XCTAssertEqual((errorBox.value as? URLError)?.code, specificError.code)
    }
}

// MARK: RequestProcessorTests.Box

private extension RequestProcessorTests {
    final class Box<T>: @unchecked Sendable {
        var value: T?
    }
}
