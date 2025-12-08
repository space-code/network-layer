//
// network-layer
// Copyright © 2024 Space Code. All rights reserved.
//

@testable import NetworkLayer
import XCTest

// MARK: - RequestBuilderTests

final class RequestBuilderTests: XCTestCase {
    // MARK: Properties

    private var parametersEncoderMock: RequestParametersEncoderMock!
    private var requestBodyEncoderMock: RequestBodyEncoderMock!
    private var queryParametersFormatterMock: QueryParametersFormatterMock!

    private var sut: RequestBuilder!

    // MARK: XCTestCase

    override func setUp() {
        super.setUp()
        parametersEncoderMock = RequestParametersEncoderMock()
        requestBodyEncoderMock = RequestBodyEncoderMock()
        queryParametersFormatterMock = QueryParametersFormatterMock()
        sut = RequestBuilder(
            parametersEncoder: parametersEncoderMock,
            requestBodyEncoder: requestBodyEncoderMock,
            queryFormatter: queryParametersFormatterMock
        )
    }

    override func tearDown() {
        parametersEncoderMock = nil
        requestBodyEncoderMock = nil
        sut = nil
        queryParametersFormatterMock = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_thatRequestBuilderThrowsAnError_whenRequestIsNotValid() {
        // given
        let request = RequestStub()

        // when
        var receivedError: NSError?
        do {
            _ = try sut.build(request, nil)
        } catch {
            receivedError = error as NSError
        }

        // then
        XCTAssertEqual(receivedError, URLError(.badURL) as NSError)
    }

    func test_thatRequestBuilderBuildsARequest() throws {
        // given
        let requestStub = RequestStub()
        requestStub.stubbedDomainName = .domainName
        requestStub.stubbedHeaders = .contentType
        requestStub.stubbedHttpMethod = .post
        requestStub.stubbedHttpBody = .dictionary(.item)
        requestStub.stubbedParameters = .contentType

        queryParametersFormatterMock.stubbedFormat = .contentType

        // when
        var invokedConfigure = false
        let request = try sut.build(requestStub) { _ in invokedConfigure = true }

        // then
        XCTAssertTrue(invokedConfigure)
        XCTAssertEqual(request?.allHTTPHeaderFields, .contentType)
        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(parametersEncoderMock.invokedEncodeParameters?.parameters, .contentType)

        if case let .dictionary(dict) = requestBodyEncoderMock.invokedEncodeParameters?.body {
            XCTAssertTrue(NSDictionary(dictionary: dict).isEqual(to: Dictionary.item))
        } else {
            XCTFail("body should be equal to a dictionary")
        }
    }
}

// MARK: - Constants

private extension String {
    static let domainName = "https://google.com"
}

private extension [String: String] {
    static let contentType = ["Content-Type": "application/json"]
}

private extension [String: Any] {
    static let item = ["Content-Type": "application/json"]
}
