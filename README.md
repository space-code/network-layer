![NetworkLayer: Network communication made easy](./Resources/network-layer.png)

<h1 align="center" style="margin-top: 0px;">network-layer</h1>

<p align="center">
<a href="https://github.com/space-code/network-layer/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/github/license/space-code/network-layer?style=flat"></a> 
<a href="https://swiftpackageindex.com/space-code/network-layer"><img alt="Swift Compatibility" src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fspace-code%2Fnetwork-layer%2Fbadge%3Ftype%3Dswift-versions"/></a> 
<a href="https://swiftpackageindex.com/space-code/network-layer"><img alt="Platform Compatibility" src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fspace-code%2Fnetwork-layer%2Fbadge%3Ftype%3Dplatforms"/></a> 
<a href="https://github.com/space-code/network-layer"><img alt="CI" src="https://github.com/space-code/network-layer/actions/workflows/ci.yml/badge.svg?branch=main"></a>
<a href="https://github.com/apple/swift-package-manager" alt="network-layer on Swift Package Manager" title="network-layer on Swift Package Manager"><img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" /></a>
<a href="https://codecov.io/gh/space-code/network-layer"><img src="https://codecov.io/gh/space-code/network-layer/graph/badge.svg?token=lWsPUf5nPL"/></a>
</p>

## Description
NetworkLayer is a modern, type-safe Swift framework for elegant network communication. Built with Swift's async/await concurrency model and actor-based architecture, it provides a robust foundation for making HTTP requests with features like authentication handling, retry policies, and request processing.

## Features

✨ **Type-Safe Requests** - Protocol-based request modeling with compile-time safety  
⚡ **Async/Await Native** - Built for modern Swift concurrency with actor-based thread safety  
🔐 **Authentication Support** - Built-in authentication interceptor with credential refresh  
🔄 **Retry Policies** - Powered by [Typhoon](https://github.com/space-code/typhoon) for robust failure handling  
🎯 **Flexible Configuration** - Customizable session configuration, decoders, and delegates  
📱 **Cross-Platform** - Works on iOS, macOS, tvOS, watchOS, and visionOS  
⚡ **Lightweight** - Minimal footprint with focused dependencies  
🧪 **Well Tested** - Comprehensive test coverage

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Usage](#usage)
  - [Basic Requests](#basic-requests)
  - [Authentication](#authentication)
  - [Retry Policies](#retry-policies)
  - [Custom Configuration](#custom-configuration)
  - [Request Validation](#request-validation)
- [Common Use Cases](#common-use-cases)
- [Communication](#communication)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [Author](#author)
- [Dependencies](#dependencies)
- [License](#license)

## Requirements

| Platform  | Minimum Version |
|-----------|----------------|
| iOS       | 13.0+          |
| macOS     | 10.15+         |
| tvOS      | 13.0+          |
| watchOS   | 7.0+           |
| visionOS  | 1.0+           |
| Xcode     | 15.3+          |
| Swift     | 5.10+           |

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/space-code/network-layer.git", from: "1.0.0")
]
```

Or add it through Xcode:

1. File > Add Package Dependencies
2. Enter package URL: `https://github.com/space-code/network-layer.git`
3. Select version requirements

## Architecture

NetworkLayer consists of two packages:

- **NetworkLayer** - Core functionality including request processing, session management, and response handling
- **NetworkLayerInterfaces** - Protocol definitions and interfaces for extensibility and testing

This separation allows for better modularity and makes it easy to mock components during testing.

## Quick Start

```swift
import NetworkLayer
import NetworkLayerInterfaces

// Define your request
struct UserRequest: IRequest {
    let userId: String
    
    var domainName: String { "https://api.example.com" }
    var path: String { "users/\(userId)" }
    var httpMethod: HTTPMethod { .get }
}

// Make the request
let requestProcessor = NetworkLayerAssembly().assemble()

do {
    let response: Response<User> = try await requestProcessor.send(UserRequest(userId: "123"))
    print("✅ User fetched: \(response.value.name)")
} catch {
    print("❌ Request failed: \(error)")
}
```

## Usage

### Basic Requests

Define requests by conforming to the `IRequest` protocol:

```swift
import NetworkLayerInterfaces

struct GetPostsRequest: IRequest {
    var domainName: String { "https://jsonplaceholder.typicode.com" }
    var path: String { "posts" }
    var httpMethod: HTTPMethod { .get }
}

struct CreatePostRequest: IRequest {
    let title: String
    let body: String
    let userId: Int
    
    var domainName: String { "https://jsonplaceholder.typicode.com" }
    var path: String { "posts" }
    var httpMethod: HTTPMethod { .post }
    var body: RequestBody? {
        .dictionary([
            "title": title,
            "body": body,
            "userId": userId
        ])
    }
}

// Usage
let requestProcessor = NetworkLayerAssembly().assemble()

// GET request
let posts: Response<[Post]> = try await requestProcessor.send(GetPostsRequest())

// POST request
let newPost: Response<Post> = try await requestProcessor.send(
    CreatePostRequest(title: "Hello", body: "World", userId: 1)
)
```

### Authentication

NetworkLayer supports authentication through the `IAuthenticationInterceptor` protocol:

```swift
import NetworkLayerInterfaces

class BearerTokenInterceptor: IAuthenticationInterceptor {
    private var token: String?
    
    func adapt(request: inout URLRequest, for session: URLSession) async throws {
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
    
    func isRequireRefresh(_ request: URLRequest, response: HTTPURLResponse) -> Bool {
        response.statusCode == 401
    }
    
    func refresh(_ request: URLRequest, with response: HTTPURLResponse, for session: URLSession) async throws {
        // Implement token refresh logic
        token = try await refreshToken()
    }
}

// Configure with authentication
let configuration = Configuration(
    sessionConfiguration: .default,
    interceptor: BearerTokenInterceptor()
)

let requestProcessor = NetworkLayerAssembly().assemble(configuration: configuration)

// Requests requiring authentication
struct SecureRequest: IRequest {
    var domainName: String { "https://api.example.com" }
    var path: String { "secure/data" }
    var httpMethod: HTTPMethod { .get }
    var requiresAuthentication: Bool { true }
}
```

### Retry Policies

Leverage [Typhoon](https://github.com/space-code/typhoon) for sophisticated retry strategies:

```swift
import Typhoon

// Configure retry policy during assembly
let requestProcessor = NetworkLayerAssembly(
    retryStrategy: .custom(
        .exponentialWithJitter(
            retry: 3,
            jitterFactor: 0.2,
            maxInterval: .seconds(30),
            multiplier: 2.0,
            duration: .seconds(1)
        )
    )
).assemble()

// Per-request retry strategy override
let response: Response<Data> = try await requestProcessor.send(
    request,
    strategy: .constant(retry: 5, duration: .seconds(2))
)

// Custom retry evaluation
let response: Response<User> = try await requestProcessor.send(
    request,
    shouldRetry: { error in
        // Only retry on network errors, not on validation failures
        if let networkError = error as? URLError {
            return networkError.code == .timedOut || networkError.code == .networkConnectionLost
        }
        return false
    }
)
```

### Custom Configuration

Customize the network layer to fit your needs:

```swift
import NetworkLayer
import NetworkLayerInterfaces

class CustomDelegate: RequestProcessorDelegate {
    func requestProcessor(
        _ processor: IRequestProcessor,
        willSendRequest request: URLRequest
    ) async throws {
        print("Sending request to: \(request.url?.absoluteString ?? "")")
    }
    
    func requestProcessor(
        _ processor: IRequestProcessor,
        validateResponse response: HTTPURLResponse,
        data: Data,
        task: URLSessionTask
    ) throws {
        guard (200...299).contains(response.statusCode) else {
            throw NetworkLayerError.invalidStatusCode(response.statusCode)
        }
    }
}

let configuration = Configuration(
    sessionConfiguration: .default,
    sessionDelegate: CustomSessionDelegate(),
    sessionDelegateQueue: .main,
    jsonDecoder: JSONDecoder(),
    interceptor: BearerTokenInterceptor()
)

let requestProcessor = NetworkLayerAssembly().assemble(
    configuration: configuration,
    delegate: CustomDelegate()
)
```

### Request Validation

Add custom validation logic for responses:

```swift
class ValidationDelegate: RequestProcessorDelegate {
    func requestProcessor(
        _ processor: IRequestProcessor,
        validateResponse response: HTTPURLResponse,
        data: Data,
        task: URLSessionTask
    ) throws {
        // Check status code
        guard (200...299).contains(response.statusCode) else {
            throw APIError.invalidStatusCode(response.statusCode)
        }
        
        // Check content type
        guard let contentType = response.value(forHTTPHeaderField: "Content-Type"),
              contentType.contains("application/json") else {
            throw APIError.invalidContentType
        }
        
        // Check response size
        guard data.count > 0 else {
            throw APIError.emptyResponse
        }
    }
}
```

## Common Use Cases

### REST API Client

```swift
import NetworkLayer
import NetworkLayerInterfaces

class APIClient {
    private let requestProcessor: IRequestProcessor
    
    init() {
        requestProcessor = NetworkLayerAssembly(
            retryStrategy: .custom(
                .exponentialWithJitter(
                    retry: 3,
                    jitterFactor: 0.2,
                    maxInterval: .seconds(30),
                    multiplier: 2.0,
                    duration: .seconds(1)
                )
            )
        ).assemble()
    }
    
    func fetchUser(id: String) async throws -> User {
        struct UserRequest: IRequest {
            let id: String
            var domainName: String { "https://api.example.com" }
            var path: String { "users/\(id)" }
            var httpMethod: HTTPMethod { .get }
        }
        
        let response: Response<User> = try await requestProcessor.send(
            UserRequest(id: id)
        )
        return response.value
    }
    
    func updateUser(_ user: User) async throws -> User {
        struct UpdateUserRequest: IRequest {
            let user: User
            var domainName: String { "https://api.example.com" }
            var path: String { "users/\(user.id)" }
            var httpMethod: HTTPMethod { .put }
            var body: RequestBody? {
                .encodable(user)
            }
        }
        
        let response: Response<User> = try await requestProcessor.send(
            UpdateUserRequest(user: user)
        )
        return response.value
    }
}
```

### Authenticated API Client

```swift
import NetworkLayer
import NetworkLayerInterfaces

class SecureAPIClient {
    private let requestProcessor: IRequestProcessor
    
    init(authToken: String) {
        class AuthInterceptor: IAuthenticationInterceptor {
            var token: String
            
            init(token: String) {
                self.token = token
            }
            
            func adapt(request: inout URLRequest, for session: URLSession) async throws {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            func isRequireRefresh(_ request: URLRequest, response: HTTPURLResponse) -> Bool {
                response.statusCode == 401
            }
            
            func refresh(_ request: URLRequest, with response: HTTPURLResponse, for session: URLSession) async throws {
                // Refresh token logic
            }
        }
        
        let configuration = Configuration(
            sessionConfiguration: .default,
            interceptor: AuthInterceptor(token: authToken)
        )
        
        requestProcessor = NetworkLayerAssembly().assemble(configuration: configuration)
    }
    
    func fetchPrivateData() async throws -> PrivateData {
        struct PrivateDataRequest: IRequest {
            var domainName: String { "https://api.example.com" }
            var path: String { "private/data" }
            var httpMethod: HTTPMethod { .get }
            var requiresAuthentication: Bool { true }
        }
        
        let response: Response<PrivateData> = try await requestProcessor.send(
            PrivateDataRequest()
        )
        return response.value
    }
}
```

## Communication

- 🐛 **Found a bug?** [Open an issue](https://github.com/space-code/network-layer/issues/new)
- 💡 **Have a feature request?** [Open an issue](https://github.com/space-code/network-layer/issues/new)
- ❓ **Questions?** [Start a discussion](https://github.com/space-code/network-layer/discussions)
- 🔒 **Security issue?** Email nv3212@gmail.com

## Documentation

Comprehensive documentation is available: [NetworkLayer Documentation](https://github.com/space-code/network-layer/blob/main/Sources/NetworkLayer/NetworkLayer.docc/NetworkLayer.md)

## Contributing

We love contributions! Please feel free to help out with this project. If you see something that could be made better or want a new feature, open up an issue or send a Pull Request.

### Development Setup

Bootstrap the development environment:

```bash
mise install
```

## Author

**Nikita Vasilev**
- Email: nv3212@gmail.com
- GitHub: [@ns-vasilev](https://github.com/ns-vasilev)

## Dependencies

This project uses several open-source packages:

* [Atomic](https://github.com/space-code/atomic) - A Swift property wrapper designed to make values thread-safe
* [Typhoon](https://github.com/space-code/typhoon) - A service for retry policies with multiple strategies
* [Mocker](https://github.com/WeTransfer/Mocker) - A library for mocking data requests using a custom URLProtocol

## License

network-layer is available under the MIT license. See the [LICENSE](https://github.com/space-code/network-layer/blob/main/LICENSE) file for more info.

---

<div align="center">

**[⬆ back to top](#network-layer)**

Made with ❤️ by [space-code](https://github.com/space-code)

</div>