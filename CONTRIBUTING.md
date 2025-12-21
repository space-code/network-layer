# Contributing to NetworkLayer

First off, thank you for considering contributing to NetworkLayer! It's people like you that make NetworkLayer such a great tool for network communication.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
  - [Development Setup](#development-setup)
  - [Project Structure](#project-structure)
- [How Can I Contribute?](#how-can-i-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Features](#suggesting-features)
  - [Improving Documentation](#improving-documentation)
  - [Submitting Code](#submitting-code)
- [Development Workflow](#development-workflow)
  - [Branching Strategy](#branching-strategy)
  - [Commit Guidelines](#commit-guidelines)
  - [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
  - [Swift Style Guide](#swift-style-guide)
  - [Code Quality](#code-quality)
  - [Testing Requirements](#testing-requirements)
- [Community](#community)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to nv3212@gmail.com.

## Getting Started

### Development Setup

1. **Fork the repository**
   ```bash
   # Click the "Fork" button on GitHub
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/network-layer.git
   cd network-layer
   ```

3. **Set up the development environment**
   ```bash
   # Bootstrap the project
   mise install
   ```

4. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

5. **Open the project in Xcode**
   ```bash
   open Package.swift
   ```

## How Can I Contribute?

### Reporting Bugs

Before creating a bug report, please check the [existing issues](https://github.com/space-code/network-layer/issues) to avoid duplicates.

When creating a bug report, include:

- **Clear title** - Describe the issue concisely
- **Reproduction steps** - Detailed steps to reproduce the bug
- **Expected behavior** - What you expected to happen
- **Actual behavior** - What actually happened
- **Environment** - OS, Xcode version, Swift version
- **Code samples** - Minimal reproducible example
- **Error messages** - Complete error output if applicable

**Example:**
```markdown
**Title:** RequestProcessor fails to refresh credentials on 401 response

**Steps to reproduce:**
1. Configure RequestProcessor with authentication interceptor
2. Make request with requiresAuthentication = true
3. Server returns 401
4. Observe that refresh is not triggered

**Expected:** Authentication interceptor should refresh credentials
**Actual:** Request fails without refresh attempt

**Environment:**
- iOS 16.0
- Xcode 14.3
- Swift 5.7

**Code:**
\`\`\`swift
let interceptor = MyAuthInterceptor()
let configuration = Configuration(
    sessionConfiguration: .default,
    interceptor: interceptor
)
let processor = NetworkLayerAssembly().assemble(configuration: configuration)

struct AuthRequest: IRequest {
    var domainName: String { "https://api.example.com" }
    var path: String { "secure/data" }
    var httpMethod: HTTPMethod { .get }
    var requiresAuthentication: Bool { true }
}

let response: Response<Data> = try await processor.send(AuthRequest())
\`\`\`
```

### Suggesting Features

We love feature suggestions! When proposing a new feature, include:

- **Problem statement** - What problem does this solve?
- **Proposed solution** - How should it work?
- **Alternatives** - What alternatives did you consider?
- **Use cases** - Real-world scenarios
- **API design** - Example code showing usage
- **Breaking changes** - Will this break existing code?

**Example:**
```markdown
**Feature:** Add request/response interceptor chain

**Problem:** Currently only one authentication interceptor is supported. Complex apps need multiple interceptors for logging, analytics, error handling, etc.

**Solution:** Add interceptor chain that executes multiple interceptors in order.

**API:**
\`\`\`swift
let configuration = Configuration(
    sessionConfiguration: .default,
    interceptors: [
        LoggingInterceptor(),
        AuthenticationInterceptor(),
        AnalyticsInterceptor()
    ]
)
\`\`\`

**Use case:** Mobile app needs to:
1. Log all requests/responses
2. Add authentication headers
3. Track API usage analytics
4. Handle rate limiting
```

### Improving Documentation

Documentation improvements are always welcome:

- **Code comments** - Add/improve inline documentation
- **DocC documentation** - Enhance documentation articles
- **README** - Fix typos, add examples
- **Guides** - Write tutorials or how-to guides
- **API documentation** - Document public APIs
- **Migration guides** - Help users upgrade versions

### Submitting Code

1. **Check existing work** - Look for related issues or PRs
2. **Discuss major changes** - Open an issue for large features
3. **Follow coding standards** - See [Coding Standards](#coding-standards)
4. **Write tests** - All code changes require tests
5. **Update documentation** - Keep docs in sync with code
6. **Create a pull request** - Use clear description

## Development Workflow

### Branching Strategy

We use a simplified branching model:

- **`main`** - Main development branch (all PRs target this)
- **`feature/*`** - New features
- **`fix/*`** - Bug fixes
- **`docs/*`** - Documentation updates
- **`refactor/*`** - Code refactoring
- **`test/*`** - Test improvements

**Branch naming examples:**
```bash
feature/interceptor-chain
fix/credential-refresh-timing
docs/update-authentication-guide
refactor/simplify-request-builder
test/add-retry-integration-tests
```

### Commit Guidelines

We use [Conventional Commits](https://www.conventionalcommits.org/) for clear, structured commit history.

**Format:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style (formatting, no logic changes)
- `refactor` - Code refactoring
- `test` - Adding or updating tests
- `chore` - Maintenance tasks
- `perf` - Performance improvements

**Scopes:**
- `core` - Core networking logic
- `processor` - RequestProcessor
- `builder` - RequestBuilder
- `auth` - Authentication
- `retry` - Retry logic
- `config` - Configuration
- `interfaces` - Protocol interfaces
- `assembly` - Dependency injection

**Examples:**
```bash
feat(auth): add interceptor chain support

Implement support for multiple interceptors that execute in sequence.
Each interceptor can modify requests and handle authentication challenges.

Closes #78

---

fix(processor): correct credential refresh detection

The refresh method was checking HTTP status codes incorrectly,
causing valid 401 responses to be ignored. Now properly delegates
to interceptor's isRequireRefresh method.

Fixes #92

---

docs(readme): add GraphQL client example

Add practical example showing how to use NetworkLayer with GraphQL APIs,
including query variables and error handling.

---

test(retry): add integration tests for retry policies

Add tests for:
- Retry with constant strategy
- Retry with exponential backoff
- Retry with custom shouldRetry evaluation
- Interaction between global and local retry evaluators
```

**Commit message rules:**
- Use imperative mood ("add" not "added")
- Don't capitalize first letter
- No period at the end
- Keep subject line under 72 characters
- Separate subject from body with blank line
- Reference issues in footer

### Pull Request Process

1. **Update your branch**
   ```bash
   git checkout main
   git pull upstream main
   git checkout feature/your-feature
   git rebase main
   ```

2. **Run tests and checks**
   ```bash
   # Run all tests
   swift test
   
   # Check test coverage
   swift test --enable-code-coverage
   
   # Run specific test suite
   swift test --filter NetworkLayerTests
   ```

3. **Push to your fork**
   ```bash
   git push origin feature/your-feature
   ```

4. **Create pull request**
   - Target the `main` branch
   - Provide clear description
   - Link related issues
   - Include examples if applicable
   - Request review from maintainers

5. **Review process**
   - Address review comments
   - Keep PR up to date with main
   - Squash commits if requested
   - Wait for CI to pass

6. **After merge**
   ```bash
   # Clean up local branch
   git checkout main
   git pull upstream main
   git branch -d feature/your-feature
   
   # Clean up remote branch
   git push origin --delete feature/your-feature
   ```

## Coding Standards

### Swift Style Guide

We follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) and [Ray Wenderlich Swift Style Guide](https://github.com/raywenderlich/swift-style-guide).

**Key points:**

1. **Naming**
   ```swift
   // ✅ Good
   func send<M: Decodable>(_ request: some IRequest) async throws -> Response<M>
   let requestProcessor: IRequestProcessor
   
   // ❌ Bad
   func doSend(_ req: Any) async throws -> Any
   let proc: Any
   ```

2. **Protocols**
   ```swift
   // ✅ Good - Use "I" prefix for protocols
   protocol IRequestProcessor {
       func send<M: Decodable>(_ request: some IRequest) async throws -> Response<M>
   }
   
   protocol IAuthenticationInterceptor {
       func adapt(request: inout URLRequest, for session: URLSession) async throws
   }
   
   // ❌ Bad
   protocol RequestProcessor { }
   protocol Authenticator { }
   ```

3. **Access Control**
   ```swift
   // ✅ Good - Explicit access control
   public actor RequestProcessor {
       private let configuration: Configuration
       private let session: URLSession
       private let requestBuilder: IRequestBuilder
       
       public func send<M: Decodable>(
           _ request: some IRequest
       ) async throws -> Response<M> {
           // Implementation
       }
   }
   ```

4. **Documentation**
   ```swift
   /// An actor responsible for executing network requests in a thread-safe manner.
   ///
   /// `RequestProcessor` manages the entire lifecycle of a request, including construction,
   /// authentication adaptation, execution, credential refreshing, and retry logic.
   ///
   /// - Note: All operations are performed within the actor's isolation domain,
   ///   ensuring thread-safe access to internal state.
   ///
   /// - Example:
   /// ```swift
   /// let processor = NetworkLayerAssembly().assemble()
   /// let response: Response<User> = try await processor.send(GetUserRequest())
   /// print("Fetched user: \(response.value.name)")
   /// ```
   public actor RequestProcessor: IRequestProcessor {
       // Implementation
   }
   ```

5. **Actor Usage**
   ```swift
   // ✅ Good - Use actors for thread-safe state management
   actor RequestProcessor {
       private let configuration: Configuration
       
       func performRequest() async throws -> Response<Data> {
           // Thread-safe access to configuration
       }
   }
   
   // ❌ Bad - Avoid @MainActor unless UI-related
   @MainActor
   class RequestProcessor { }
   ```

### Code Quality

- **No force unwrapping** - Use optional binding or guards
- **No force casting** - Use conditional casting
- **No magic numbers** - Use named constants
- **Single responsibility** - One class, one purpose
- **DRY principle** - Don't repeat yourself
- **SOLID principles** - Follow SOLID design
- **Actor isolation** - Respect Swift concurrency boundaries

**Example:**
```swift
// ✅ Good
private enum NetworkConstants {
    static let defaultTimeout: TimeInterval = 60
    static let maxRetryAttempts = 3
}

guard let urlRequest = try requestBuilder.build(request, configure) else {
    throw NetworkLayerError.badURL
}

// ❌ Bad
let timeout = 60.0  // Magic number
let request = try requestBuilder.build(request, configure)!  // Force unwrap
```

### Testing Requirements

All code changes must include tests:

1. **Unit tests** - Test individual components
2. **Integration tests** - Test component interactions
3. **Edge cases** - Test boundary conditions
4. **Error handling** - Test failure scenarios
5. **Concurrency tests** - Test actor isolation and async behavior
6. **Mock tests** - Use Mocker for network mocking

**Coverage requirements:**
- New code: minimum 80% coverage
- Modified code: maintain or improve existing coverage
- Critical paths: 100% coverage

**Test structure:**
```swift
import XCTest
@testable import NetworkLayer
import Mocker

final class RequestProcessorTests: XCTestCase {
    var sut: RequestProcessor!
    var configuration: Configuration!
    var mockSession: URLSession!
    
    override func setUp() {
        super.setUp()
        
        let mockConfiguration = URLSessionConfiguration.default
        mockConfiguration.protocolClasses = [MockingURLProtocol.self]
        
        configuration = Configuration(sessionConfiguration: mockConfiguration)
        sut = NetworkLayerAssembly().assemble(configuration: configuration)
    }
    
    override func tearDown() {
        sut = nil
        configuration = nil
        mockSession = nil
        super.tearDown()
    }
    
    // MARK: - Success Tests
    
    func testSend_WithValidRequest_ReturnsDecodedResponse() async throws {
        // Given
        let expectedUser = User(id: "123", name: "John Doe")
        let requestURL = URL(string: "https://api.example.com/users/123")!
        
        let mockedData = try JSONEncoder().encode(expectedUser)
        let mock = Mock(url: requestURL, dataType: .json, statusCode: 200, data: [.get: mockedData])
        mock.register()
        
        struct GetUserRequest: IRequest {
            var domainName: String { "https://api.example.com" }
            var path: String { "users/123" }
            var httpMethod: HTTPMethod { .get }
        }
        
        // When
        let response: Response<User> = try await sut.send(GetUserRequest())
        
        // Then
        XCTAssertEqual(response.value.id, expectedUser.id)
        XCTAssertEqual(response.value.name, expectedUser.name)
    }
    
    // MARK: - Failure Tests
    
    func testSend_WithNetworkError_ThrowsError() async {
        // Given
        let requestURL = URL(string: "https://api.example.com/users/123")!
        let mock = Mock(url: requestURL, dataType: .json, statusCode: 500, data: [.get: Data()])
        mock.register()
        
        struct GetUserRequest: IRequest {
            var domainName: String { "https://api.example.com" }
            var path: String { "users/123" }
            var httpMethod: HTTPMethod { .get }
        }
        
        // Then
        await XCTAssertThrowsError(
            try await sut.send(GetUserRequest()) as Response<User>
        )
    }
    
    // MARK: - Authentication Tests
    
    func testSend_WithAuthentication_AdaptsRequest() async throws {
        // Given
        let token = "test-token"
        let interceptor = MockAuthInterceptor(token: token)
        let config = Configuration(
            sessionConfiguration: .default,
            interceptor: interceptor
        )
        sut = NetworkLayerAssembly().assemble(configuration: config)
        
        struct AuthRequest: IRequest {
            var domainName: String { "https://api.example.com" }
            var path: String { "secure" }
            var httpMethod: HTTPMethod { .get }
            var requiresAuthentication: Bool { true }
        }
        
        // When/Then
        // Verify interceptor was called with correct parameters
    }
    
    // MARK: - Retry Tests
    
    func testSend_WithRetryPolicy_RetriesOnFailure() async throws {
        // Given
        let retryService = RetryPolicyService(
            strategy: .constant(retry: 2, duration: .milliseconds(100))
        )
        sut = NetworkLayerAssembly().assemble(
            configuration: configuration,
            retryPolicyService: retryService
        )
        
        var attemptCount = 0
        
        // When/Then
        // Verify retry behavior
    }
    
    // MARK: - Concurrency Tests
    
    func testSend_WithConcurrentRequests_HandlesAllRequests() async throws {
        // Given
        let requestCount = 10
        
        // When
        let responses = try await withThrowingTaskGroup(of: Response<User>.self) { group in
            for i in 0..<requestCount {
                group.addTask {
                    try await self.sut.send(GetUserRequest(id: "\(i)"))
                }
            }
            
            var results: [Response<User>] = []
            for try await response in group {
                results.append(response)
            }
            return results
        }
        
        // Then
        XCTAssertEqual(responses.count, requestCount)
    }
}

// MARK: - Test Helpers

private struct User: Codable, Equatable {
    let id: String
    let name: String
}

private class MockAuthInterceptor: IAuthenticationInterceptor {
    let token: String
    
    init(token: String) {
        self.token = token
    }
    
    func adapt(request: inout URLRequest, for session: URLSession) async throws {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    
    func isRequireRefresh(_ request: URLRequest, response: HTTPURLResponse) -> Bool {
        response.statusCode == 401
    }
    
    func refresh(
        _ request: URLRequest,
        with response: HTTPURLResponse,
        for session: URLSession
    ) async throws {
        // Mock refresh logic
    }
}
```

## Community

- **Discussions** - Join [GitHub Discussions](https://github.com/space-code/network-layer/discussions)
- **Issues** - Track [open issues](https://github.com/space-code/network-layer/issues)
- **Pull Requests** - Review [open PRs](https://github.com/space-code/network-layer/pulls)

## Recognition

Contributors are recognized in:
- GitHub contributors page
- Release notes
- Project README (for significant contributions)

## Questions?

- Check [existing issues](https://github.com/space-code/network-layer/issues)
- Search [discussions](https://github.com/space-code/network-layer/discussions)
- Ask in [Q&A discussions](https://github.com/space-code/network-layer/discussions/categories/q-a)
- Email the maintainer: nv3212@gmail.com

---

Thank you for contributing to NetworkLayer! 🎉

Your efforts help make network communication better for everyone.