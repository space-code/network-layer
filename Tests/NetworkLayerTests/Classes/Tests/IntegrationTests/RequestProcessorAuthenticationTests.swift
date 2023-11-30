//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import Foundation
@testable import NetworkLayer
import NetworkLayerInterfaces
import Typhoon
import XCTest

// MARK: - RequestProcessorAuthenicationTests

final class RequestProcessorAuthenicationTests: XCTestCase {
    // MARK: Tests

    func test_thatRequestProcessorAuthenticatesRequest_whenTokenIsCorrect() async throws {
        // given
        let interceptor = AuthInterceptor()
        let sut = RequestProcessor.mock(interceptor: interceptor)

        interceptor.token = .init(token: .token, expiresDate: Date())

        DynamicStubs.register(stubs: [.user], statusCode: 200)

        let request = makeRequest(.user)

        // when
        let _: Response<User> = try await sut.send(request)
    }

    func test_thatRequestProcessorAuthenticatesRequest_whenTokenIsInvalid() async throws {
        // given
        let interceptor = AuthInterceptor()
        let sut = RequestProcessor.mock(interceptor: interceptor)

        interceptor.token = .init(token: .token, expiresDate: Date())

        DynamicStubs.register(stubs: [.user], statusCode: 401)

        let request = makeRequest(.user)

        // when
        let _: Response<User> = try await sut.send(request)
    }

    func test_thatRequestProcessorAuthenticatesRequest_whenTokenExpired() async throws {
        // given
        let interceptor = AuthInterceptor()
        let sut = RequestProcessor.mock(interceptor: interceptor)

        interceptor.token = .init(token: .token, expiresDate: Date(timeIntervalSinceNow: 1001))

        DynamicStubs.register(stubs: [.user], statusCode: 200)

        let request = makeRequest(.user)

        // when
        let _: Response<User> = try await sut.send(request)
    }

    func test_thatRequestProcessorThrowsAnError_whenInterceptorAdaptDidFail() async throws {
        try await test_failAuthentication(adaptError: URLError(.unknown), refreshError: nil, expectedError: URLError(.unknown))
    }

    func test_thatRequestProcessorThrowsAnError_whenInterceptorRefreshDidFail() async throws {
        try await test_failAuthentication(
            adaptError: nil,
            refreshError: URLError(.unknown),
            expectedError: RetryPolicyError.retryLimitExceeded
        )
    }

    // MARK: Private

    private func test_failAuthentication(adaptError: Error?, refreshError: Error?, expectedError: Error) async throws {
        class FailInterceptor: IAuthenticatorInterceptor {
            let adaptError: Error?
            let refreshError: Error?

            init(adaptError: Error?, refreshError: Error?) {
                self.adaptError = adaptError
                self.refreshError = refreshError
            }

            func adapt(request _: inout URLRequest, for _: URLSession) async throws {
                guard let adaptError = adaptError else { return }
                throw adaptError
            }

            func refresh(_: URLRequest, with _: HTTPURLResponse, for _: URLSession) async throws {
                guard let refreshError = refreshError else { return }
                throw refreshError
            }

            func isRequireRefresh(_: URLRequest, response _: HTTPURLResponse) -> Bool {
                true
            }
        }

        // given
        let interceptor = FailInterceptor(adaptError: adaptError, refreshError: refreshError)
        let sut = RequestProcessor.mock(interceptor: interceptor)

        let request = makeRequest(.user)

        DynamicStubs.register(stubs: [.user], statusCode: 200)

        // when
        do {
            let _: Response<User> = try await sut.send(request)
        } catch {
            XCTAssertEqual(error as NSError, expectedError as NSError)
        }
    }

    private func makeRequest(_ path: String) -> IRequest {
        let request = RequestStub()
        request.stubbedDomainName = "https://github.com"
        request.stubbedPath = path
        request.stubbedRequiresAuthentication = true
        return request
    }
}

// MARK: - AuthInterceptor

private final class AuthInterceptor: IAuthenticatorInterceptor {
    var token: Token!

    private var attempts = 0

    func adapt(request: inout URLRequest, for _: URLSession) async throws {
        request.addValue("Bearer \(token.token)", forHTTPHeaderField: "Authorization")
    }

    func refresh(_: URLRequest, with _: HTTPURLResponse, for _: URLSession) async throws {
        if token.expiresDate < Date() {
            token = Token(token: .token, expiresDate: Date(timeIntervalSinceNow: 1000))
        }
    }

    func isRequireRefresh(_: URLRequest, response: HTTPURLResponse) -> Bool {
        if response.statusCode == 401, attempts == 0 {
            attempts += 1
            return true
        }
        return false
    }
}

// MARK: - Token

private struct Token {
    let token: String
    let expiresDate: Date
}

// MARK: - Stubs

private extension StubResponse {
    static let user = StubResponse(name: .user, fileURL: MockedData.userJSON, httpMethod: .get)
}

// MARK: - Constants

private extension String {
    static let user = "user"
    static let token = "token"
}
