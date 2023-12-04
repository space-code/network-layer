//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

@testable import NetworkLayer
import NetworkLayerInterfaces
import Typhoon
import XCTest

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
            delegate: delegateMock,
            interceptor: interceptorMock
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

    // MARK: Tests

    func test_thatRequestProcessorSignsRequest_whenRequestRequiresAuthentication() async {
        // given
        requestBuilderMock.stubbedBuildResult = URLRequest.fake()
        dataRequestHandler.stubbedStartDataTask = .init(data: Data(), response: .init(), task: .fake())

        let request = RequestMock()
        request.stubbedRequiresAuthentication = true

        // when
        do {
            let _ = try await sut.send(request) as Response<Int>
        } catch {}

        // then
        XCTAssertTrue(interceptorMock.invokedAdapt)
        XCTAssertFalse(interceptorMock.invokedRefresh)
    }

    func test_thatRequestProcessorDoesNotSignRequest_whenRequestDoesNotRequireAuthentication() async {
        // given
        requestBuilderMock.stubbedBuildResult = URLRequest.fake()
        dataRequestHandler.stubbedStartDataTask = .init(data: Data(), response: .init(), task: .fake())

        let request = RequestMock()
        request.stubbedRequiresAuthentication = false

        // when
        do {
            let _ = try await sut.send(request) as Response<Int>
        } catch {}

        // then
        XCTAssertFalse(interceptorMock.invokedAdapt)
        XCTAssertFalse(interceptorMock.invokedRefresh)
    }

    func test_thatRequestProcessorRefreshesCredential_whenCredentialIsNotValid() async {
        // given
        requestBuilderMock.stubbedBuildResult = URLRequest.fake()
        dataRequestHandler.stubbedStartDataTask = .init(data: Data(), response: HTTPURLResponse(), task: .fake())
        interceptorMock.stubbedIsRequireRefreshResult = true

        let request = RequestMock()
        request.stubbedRequiresAuthentication = true

        // when
        do {
            let _ = try await sut.send(request) as Response<Int>
        } catch {}

        // then
        XCTAssertTrue(interceptorMock.invokedAdapt)
        XCTAssertTrue(interceptorMock.invokedRefresh)
    }

    func test_thatRequestProcessorDoesNotRefreshesCredential_whenRequestDoesNotRequireAuthentication() async {
        // given
        requestBuilderMock.stubbedBuildResult = URLRequest.fake()
        dataRequestHandler.startDataTaskThrowError = URLError(.unknown)

        let request = RequestMock()
        request.stubbedRequiresAuthentication = false

        // when
        do {
            let _ = try await sut.send(request) as Response<Int>
        } catch {}

        // then
        XCTAssertFalse(interceptorMock.invokedAdapt)
        XCTAssertFalse(interceptorMock.invokedRefresh)
    }
}
