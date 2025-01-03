//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
import Mocker
@testable import NetworkLayer
import NetworkLayerInterfaces
import Typhoon
import XCTest

// MARK: - RequestProcessorRequestTests

final class RequestProcessorRequestTests: XCTestCase {
    // MARK: Tests

    func test_thatRequestProcessorSendsASimpleRequest() async throws {
        // given
        DynamicStubs.register(stubs: [.user])

        let sut = RequestProcessor.mock()
        let request = makeRequest(.user)

        // when
        let user: Response<User> = try await sut.send(request)

        // then
        XCTAssertEqual(user.data.id, 1)
        XCTAssertNotNil(user.data.avatarUrl)
    }

    func test_thatRequestProcessorThrowsRretryLimitExceededError_whenRequestDidFail() async {
        // given
        DynamicStubs.register(stubs: [.user], statusCode: 500)

        let delegate = GitHubDelegate()
        let sut = RequestProcessor.mock(requestProcessorDelegate: delegate)
        let request = makeRequest(.user)

        // when
        do {
            let _: Response<User> = try await sut.send(request)
        } catch {
            XCTAssertEqual(error as NSError, RetryPolicyError.retryLimitExceeded as NSError)
        }
    }

    func test_thatRequestProcessorConfigureARequest() async throws {
        // given
        DynamicStubs.register(stubs: [.updateProfile])

        let endpointURL = URL(string: "\(String.domain)/\(String.updateProfile)")
        let delegateMock = RequestProcessorDelegateMock()

        let sut = RequestProcessor.mock(requestProcessorDelegate: delegateMock)
        let request = makeRequest(.user)

        // when
        let user: Response<User> = try await sut.send(request) { urlRequest in
            urlRequest.url = endpointURL
        }

        // then
        XCTAssertEqual(user.data.id, 1)
        XCTAssertNotNil(user.data.avatarUrl)
        XCTAssertEqual(delegateMock.invokedRequestProcessorParameters?.request.httpMethod, HTTPMethod.get.rawValue)
        XCTAssertEqual(delegateMock.invokedRequestProcessorParameters?.request.url, endpointURL)
    }

    // MARK: Private

    private func makeRequest(_ path: String) -> IRequest {
        let request = RequestStub()
        request.stubbedDomainName = .domain
        request.stubbedPath = path
//        request.httpMethod = .get
        return request
    }
}

// MARK: - GitHubDelegate

private final class GitHubDelegate: RequestProcessorDelegate {
    func requestProcessor(
        _: NetworkLayerInterfaces.IRequestProcessor,
        validateResponse response: HTTPURLResponse,
        data _: Data,
        task _: URLSessionTask
    ) throws {
        if !(200 ..< 300).contains(response.statusCode) {
            throw URLError(.unknown)
        }
    }
}

// MARK: - Stubs

private extension StubResponse {
    static let user = StubResponse(name: .user, fileURL: MockedData.userJSON, httpMethod: .get)
    static let updateProfile = StubResponse(name: .updateProfile, fileURL: MockedData.userJSON, httpMethod: .get)
}

private extension String {
    static let user = "user"
    static let updateProfile = "updateProfile"
    static let domain = "https://github.com"
}
