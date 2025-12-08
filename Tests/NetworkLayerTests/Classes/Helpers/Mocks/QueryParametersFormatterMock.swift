//
// network-layer
// Copyright © 2025 Space Code. All rights reserved.
//

@testable import NetworkLayer

final class QueryParametersFormatterMock: IQueryParametersFormatter {
    var invokedFormat = false
    var invokedFormatCount = 0
    var invokedFormatParameters: ([AnyHashable: Any], Void)?
    var invokedFormatParametersList = [([AnyHashable: Any], Void)]()
    var stubbedFormat: [String: String]!
    func format(rawParameters: [AnyHashable: Any]) -> [String: String] {
        invokedFormat = true
        invokedFormatCount += 1
        invokedFormatParameters = (rawParameters, ())
        invokedFormatParametersList.append((rawParameters, ()))
        return stubbedFormat
    }
}
