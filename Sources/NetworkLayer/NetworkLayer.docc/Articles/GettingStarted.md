# Getting Started with Network Layer

## Defining a Request

Before sending a request to a web server, it is necessary to define a request model. For this, define a new `struct` object that conforms to `IRequest` protocol.

```swift
import NetworkLayerInterfaces

struct UserRequest: IRequest {
    // MARK: Properties

    private let id: Int

    // MARK: Initialization

    init(id: Int) {
        self.id = id
    }

    // MARK: IRequest

    /// The base `URL` for the resource.
    var domainName: String { 
        "https://example.com"
    }

    /// The endpoint path.
    var path: String { 
        "user"
    }

    /// A dictionary that contains the parameters to be encoded into the request.
    var parameters: [String: String]? { 
        ["user_id": id]
    }

    /// A Boolean value indicating whether authentication is required.
    var requiresAuthentication: Bool { 
        true
    }

    /// The HTTP method.
    var httpMethod: HTTPMethod { 
        .get
    }
}
```

## Defining a Response Model

While the `network-layer` returns a `Response<T>` object that expects a decodable object, it is necessary to define a response model.

```swift
import NetworkLayerInterfaces

struct UserResponse: Decodable {
    let id: Int
    let userName: String
}
```

## Usage

```swift
import NetworkLayerInterfaces

let request = UserRequest(id: 1)

do {
    let user = try await requestProcessor.send(request)
} catch {
    // Catch an error here
}

```
