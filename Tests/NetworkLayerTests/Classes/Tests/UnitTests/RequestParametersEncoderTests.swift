//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
@testable import NetworkLayer
import XCTest

// MARK: - RequestParametersEncoderTests

final class RequestParametersEncoderTests: XCTestCase {
    // MARK: Properties

    private var sut: RequestParametersEncoder!

    // MARK: XCTestCase

    override func setUp() {
        super.setUp()
        sut = RequestParametersEncoder()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_thatRequestParametersEncoderEncodesParametersIntoRequest() throws {
        // given
        var requestMock = URLRequest.fake(string: .domainName)

        // when
        try sut.encode(parameters: .parameters, to: &requestMock)

        // then
        XCTAssertEqual(requestMock.url?.absoluteString, "https://google.com?id=1")
    }

    func test_thatRequestParametersEncoderThrowsAnError_whenURLIsNotValid() {
        // given
        var requestMock = URLRequest.fake(string: .domainName)
        requestMock.url = nil

        // when
        var receivedError: NSError?
        do {
            try sut.encode(parameters: .parameters, to: &requestMock)
        } catch {
            receivedError = error as NSError
        }

        // then
        XCTAssertEqual(receivedError, URLError(.badURL) as NSError)
    }
}

// MARK: - Constants

private extension String {
    static let domainName = "https://google.com"
}

private extension Dictionary where Self.Key == String, Self.Value == String {
    static let parameters = ["id": "1"]
}
