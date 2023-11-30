//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

@testable import NetworkLayer
import XCTest

// MARK: - RequestBodyEncoderTests

final class RequestBodyEncoderTests: XCTestCase {
    // MARK: Properties

    private var sut: RequestBodyEncoder!

    // MARK: XCTestCase

    override func setUp() {
        super.setUp()
        sut = RequestBodyEncoder(jsonEncoder: JSONEncoder())
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_thatRequestBodyEncoderEncodesBodyIntoRequest_whenTypeIsData() throws {
        // given
        var requestFake = URLRequest.fake()
        let data = Data()

        // when
        try sut.encode(body: .data(data), to: &requestFake)

        // then
        XCTAssertEqual(requestFake.httpBody, data)
    }

    func test_thatRequestBodyEncoderEncodesBodyIntoRequest_whenTypeIsDictonary() throws {
        // given
        var requestFake = URLRequest.fake()
        let dictonary = ["test": "test"]

        // when
        try sut.encode(body: .dictonary(dictonary), to: &requestFake)

        // then
        let data = try JSONSerialization.data(withJSONObject: dictonary)
        XCTAssertEqual(requestFake.httpBody, data)
    }

    func test_thatRequestBodyEncoderEncodesBodyIntoRequest_whenTypeIsEncodable() throws {
        // given
        var requestFake = URLRequest.fake()
        let object = DummyObject()

        // when
        try sut.encode(body: .encodable(object), to: &requestFake)

        // then
        let data = try JSONEncoder().encode(object)
        XCTAssertEqual(requestFake.httpBody, data)
    }
}

// MARK: RequestBodyEncoderTests.DummyObject

private extension RequestBodyEncoderTests {
    struct DummyObject: Encodable {}
}
