# ``NetworkLayer``

The library for network communication.

## Overview

The `network-layer` provides a simple interface for communication, making it very easy to send a request to a web server.

```swift
import NetworkLayer

let requestProcessor = NetworkLayerAssembly().assemble()
let user: User = try await requestProcessor.send(request)
```

The `network-layer` separates into two modules: `NetworkLayer`, which contains core functionality, and `NetworkLayerInterfaces`, which only contains public protocols for this framework.

The library supports authentication, retrying requests, and more.

## License

network-layer is available under the MIT license. See the LICENSE file for more info.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:Authentication>
- <doc:Retry>

<!--### Network Layer Creation-->
<!---->
<!--- ``INetworkLayerAssembly``-->
<!---->
<!--### Request and Response Models-->
<!---->
<!--- ``Configuration``-->
<!--- ``HTTPMethod``-->
<!--- ``RequestBody``-->
<!--- ``IRequest``-->
<!--- ``Response``-->
<!---->
<!--### Errors-->
<!---->
<!--- ``NetworkLayerError``-->
<!--- ``AuthenticatorInterceptorError``-->
<!---->
<!--### Authentication-->
<!---->
<!--- ``IAuthenticationCredential``-->
<!--- ``IAuthenticationInterceptor``-->
<!--- ``IAuthenticator``-->
<!---->
<!--### Services-->
<!---->
<!--- ``IDataRequestHandler``-->
<!--- ``IRequestBuilder``-->
<!--- ``IRequestProcessor``-->
<!--- ``RequestProcessorDelegate``-->
