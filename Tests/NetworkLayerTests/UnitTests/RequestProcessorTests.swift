//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

@testable import NetworkLayer
import NetworkLayerInterfaces
import XCTest

final class RequestProcessorTests: XCTestCase {
    // MARK: Properties

    private var requestBuilderMock: RequestBuilderMock!
    private var dataRequestHandler: DataRequestHandlerMock!
    private var retryPolicyMock: RetryPolicyServiceMock<Int>!
    private var delegateMock: RequestProcessorDelegateMock!

    private var sut: RequestProcessor!

    // MARK: XCTestCase

    override func setUp() {
        super.setUp()
        requestBuilderMock = RequestBuilderMock()
        dataRequestHandler = DataRequestHandlerMock()
        retryPolicyMock = RetryPolicyServiceMock<Int>()
        delegateMock = RequestProcessorDelegateMock()
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
            delegate: delegateMock
        )
    }

    override func tearDown() {
        requestBuilderMock = nil
        dataRequestHandler = nil
        retryPolicyMock = nil
        delegateMock = nil
        sut = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_thatRequestProcessorInvokesDelegate_whenRequestWillPerform() async throws {
        // given
        let request = RequestStub()

        // when
        let _ = try await sut.send(request) as Int

        // then
//        XCTAssertEqual(request.re, <#T##expression2: Equatable##Equatable#>)
    }
}
