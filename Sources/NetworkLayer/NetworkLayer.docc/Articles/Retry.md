# Retry

Learn how to retry failed requests.

## Overview

The `network-layer` is implemented using the `Typhoon` framework to handle the retrying of failed requests. You can read more about `Typhoon` framework [here](https://github.com/space-code/typhoon/).

## Retrying Failed Requests

By default, the `network-layer` attempts to resend a failed request five times. If you wish to customize this behavior, you can pass the desired value to an assembly of the `RequestProcessor`.

```swift
import NetworkLayer
import NetworkLayerInterfaces

let requestProcessor = NetworkLayerAssembly.assemble(retryPolicyStrategy: .constant(retry: 10, duration: .seconds(1)))
```

> Tip: `typhoon` framework provides different strategies for retrying failed request. You can read more [here](https://github.com/space-code/typhoon).

This behavior will be applied to all future requests. 

In case you desire to customize a particular request, you can pass the desired strategy to that specific request:

```swift
import NetworkLayerInterfaces

let request = UserRequest(id: 1)
let user: Response<User> = try await requestProcessor.send(request, strategy: .constant(retry: 10, duration: .seconds(1)))
```
