![NetworkLayer: Network communication made easy](https://raw.githubusercontent.com/space-code/network-layer/dev/Resources/network-layer.png)

<h1 align="center" style="margin-top: 0px;">network-layer</h1>

<p align="center">
<a href="https://github.com/space-code/network-layer/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/github/license/space-code/network-layer?style=flat"></a> 
<a href="https://swiftpackageindex.com/space-code/network-layer"><img alt="Swift Compatibility" src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fspace-code%2Fnetwork-layer%2Fbadge%3Ftype%3Dswift-versions"/></a> 
<a href="https://swiftpackageindex.com/space-code/network-layer"><img alt="Platform Compatibility" src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fspace-code%2Fnetwork-layer%2Fbadge%3Ftype%3Dplatforms"/></a> 
<a href="https://github.com/space-code/network-layer"><img alt="CI" src="https://github.com/space-code/network-layer/actions/workflows/ci.yml/badge.svg?branch=main"></a>
<a href="https://github.com/apple/swift-package-manager" alt="network-layer on Swift Package Manager" title="network-layer on Swift Package Manager"><img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" /></a>
<a href="https://codecov.io/gh/space-code/network-layer" > <img src="https://codecov.io/gh/space-code/network-layer/graph/badge.svg?token=lWsPUf5nPL"/></a>
</p>

## Description
`network-layer` is a library for network communication.

- [Usage](#usage)
- [Documentation](#documentation)
- [Requirements](#requirements)
- [Installation](#installation)
- [Communication](#communication)
- [Contributing](#contributing)
- [Author](#author)
- [Dependencies](#dependencies)
- [License](#license)

## Usage

```swift
import NetworkLayer
import NetworkLayerInterfaces

struct Request: IRequest {
    var domainName: String { 
        "https://example.com"
    }

    var path: String { 
        "user"
    }

    var httpMethod: HTTPMethod { 
        .get
    }
}

let request = Request()
let requestProcessor = NetworkLayerAssembly().assemble()
let user: User = try await requestProcessor.send(request)
```

## Documentation

Check out [network-layer documentation](https://github.com/space-code/network-layer/blob/main/Sources/NetworkLayer/NetworkLayer.docc/NetworkLayer.md).

## Requirements
- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 7.0+ / visionOS 1.0+
- Xcode 14.0
- Swift 5.7

## Installation
### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but `network-layer` does support its use on supported platforms.

Once you have your Swift package set up, adding `network-layer` as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/space-code/network-layer.git", .upToNextMajor(from: "1.0.0"))
]
```

## Communication
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Contributing
Bootstrapping development environment

```
make bootstrap
```

Please feel free to help out with this project! If you see something that could be made better or want a new feature, open up an issue or send a Pull Request!

## Author
Nikita Vasilev, nv3212@gmail.com

## Dependencies
This project uses several open-source packages:

* [Atomic](https://github.com/space-code/atomic) is a Swift property wrapper designed to make values thread-safe.
* [Typhoon](https://github.com/space-code/typhoon) is a service for retry policies.
* [Mocker](https://github.com/WeTransfer/Mocker) is a library written in Swift which makes it possible to mock data requests using a custom `URLProtocol`.

## License
network-layer is available under the MIT license. See the LICENSE file for more info.
