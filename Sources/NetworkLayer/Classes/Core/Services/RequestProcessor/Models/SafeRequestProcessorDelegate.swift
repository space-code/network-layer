//
// network-layer
// Copyright © 2024 Space Code. All rights reserved.
//

import NetworkLayerInterfaces

final class SafeRequestProcessorDelegate: @unchecked Sendable {
    private weak var delegate: RequestProcessorDelegate?

    init(delegate: RequestProcessorDelegate? = nil) {
        self.delegate = delegate
    }

    var wrappedValue: RequestProcessorDelegate? {
        get { delegate }
        set { delegate = newValue }
    }
}
