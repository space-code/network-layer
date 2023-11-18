//
// network-layer
// Copyright © 2023 Space Code. All rights reserved.
//

import NetworkLayer
import NetworkLayerInterfaces
import XCTest

final class AuthenticationInterceptorTests: XCTestCase {
    // MARK: Properties

    private var authenticatorMock: AuthenticatorMock!

    private var sut: AuthenticatorInterceptor<AuthenticatorMock>!

    // MARK: XCTestCase

    override func setUp() {
        super.setUp()
        authenticatorMock = AuthenticatorMock()
        sut = AuthenticatorInterceptor(
            authenticator: authenticatorMock,
            credential: nil
        )
    }

    override func tearDown() {
        authenticatorMock = nil
        sut = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_thatAuthenticatorInterceptorThrowsAnErrorOnAdaptRequest_whenCredentialIsMissing() async throws {
        // given
        var requestMock = URLRequest.fake()

        // when
        var receivedError: NSError?
        do {
            try await sut.adapt(request: &requestMock, for: .shared)
        } catch {
            receivedError = error as NSError
        }

        // then
        XCTAssertEqual(receivedError, AuthenticatorInterceptorError.missingCredential as NSError)
    }

    func test_thatAuthenticatorInterceptorAdaptsRequest_whenCredentialIsNotMissingAndValid() async throws {
        // given
        let credentialStub = AuthenticationCredentialStub()
        var requestMock = URLRequest.fake()
        credentialStub.stubbedRequiresRefresh = false

        sut.credential = credentialStub

        // when
        try await sut.adapt(request: &requestMock, for: .shared)

        // then
        XCTAssertEqual(authenticatorMock.invokedApplyCount, 1)
    }

    func test_thatAuthenticatorInterceptorAdaptsRequest_whenCredentialIsNotMissingAndNotValid() async throws {
        // given
        var requestMock = URLRequest.fake()

        let credentialStub = AuthenticationCredentialStub()
        credentialStub.stubbedRequiresRefresh = true

        authenticatorMock.stubbedRefresh = AuthenticationCredentialStub()
        sut.credential = credentialStub

        // when
        try await sut.adapt(request: &requestMock, for: .shared)

        // then
        XCTAssertEqual(authenticatorMock.invokedRefreshCount, 1)
    }

    func test_thatAuthenticatorInterceptorRefreshesCredential() async throws {
        // given
        let requestMock = URLRequest.fake()

        sut.credential = AuthenticationCredentialStub()
        authenticatorMock.stubbedRefresh = AuthenticationCredentialStub()
        authenticatorMock.stubbedDidRequestResult = true
        authenticatorMock.stubbedIsRequestResult = true

        // when
        try await sut.refresh(requestMock, with: .init(), for: .shared, dutTo: URLError(.unknown))

        // then
        XCTAssertEqual(authenticatorMock.invokedRefreshCount, 1)
    }

    func test_thatAuthenticatorInterceptorDoesNotRefreshCredential_whenRequestDidNotFailDueToAuthenticationError() async throws {
        // given
        let requestMock = URLRequest.fake()

        authenticatorMock.stubbedDidRequestResult = false

        // when
        try await sut.refresh(requestMock, with: .init(), for: .shared, dutTo: URLError(.unknown))

        // then
        XCTAssertFalse(authenticatorMock.invokedRefresh)
        XCTAssertEqual(authenticatorMock.invokedDidRequestCount, 1)
    }

    func test_thatAuthenticatorInterceptorThrowsCredentialIsMissingError_whenCredentialIsNil() async throws {
        // given
        let requestMock = URLRequest.fake()

        authenticatorMock.stubbedDidRequestResult = true

        // when
        var receivedError: NSError?
        do {
            try await sut.refresh(requestMock, with: .init(), for: .shared, dutTo: URLError(.unknown))
        } catch {
            receivedError = error as NSError
        }

        // then
        XCTAssertFalse(authenticatorMock.invokedRefresh)
        XCTAssertEqual(receivedError, AuthenticatorInterceptorError.missingCredential as NSError)
    }

    func test_thatAuthenticatorInterceptorDoesNotRefreshCredential_whenRequestIsNotAuthenticatedWithCredential() async throws {
        // given
        let requestMock = URLRequest.fake()

        sut.credential = AuthenticationCredentialStub()
        authenticatorMock.stubbedDidRequestResult = true

        // when
        try await sut.refresh(requestMock, with: .init(), for: .shared, dutTo: URLError(.unknown))

        // then
        XCTAssertFalse(authenticatorMock.invokedRefresh)
    }
}
