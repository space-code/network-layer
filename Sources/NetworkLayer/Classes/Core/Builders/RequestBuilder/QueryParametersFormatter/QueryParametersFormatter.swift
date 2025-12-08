//
// network-layer
// Copyright © 2025 Space Code. All rights reserved.
//

import Foundation
import NetworkLayerInterfaces

// MARK: - IQueryParametersFormatter

protocol IQueryParametersFormatter {
    func format(rawParameters: [AnyHashable: Any]) -> [String: String]
}

// MARK: - QueryParametersFormatter

final class QueryParametersFormatter: IQueryParametersFormatter {
    // MARK: Properties

    // Properties
    private let allowedCharacters: CharacterSet = {
        var restricted = CharacterSet(charactersIn: ":/?#[]@!$ &''()*+,;=\"<>%{}|\\^~`")
        restricted.formUnion(.newlines)
        return restricted.inverted
    }()

    // MARK: Initialization

    init() {}

    // MARK: Internal

    func format(rawParameters: [AnyHashable: Any]) -> [String: String] {
        var result: [String: String] = [:]
        rawParameters.forEach { key, value in
            guard
                let encodedKey = convertKeyToEncodedString(key),
                let encodedValue = convertValueToEncodedString(value)
            else {
                return
            }
            result[encodedKey] = encodedValue
        }
        return result
    }

    // MARK: - Private

    private func convertKeyToEncodedString(_ key: AnyHashable) -> String? {
        switch key {
        case let string as String:
            return encodeQueryComponent(string)
        case let encodedComponent as SpecificEncodedComponent:
            return encodedComponent.encodedValue
        case let convertible as CustomStringConvertible:
            return encodeQueryComponent(convertible.description)
        }
    }

    private func convertValueToEncodedString(_ value: Any) -> String? {
        switch value {
        case let string as String:
            return encodeQueryComponent(string)
        case is [Any], is [String: Any]:
            guard
                let data = try? JSONSerialization.data(withJSONObject: value, options: [.sortedKeys, .prettyPrinted]),
                let jsonString = String(data: data, encoding: .utf8)
            else {
                return nil
            }
            return encodeQueryComponent(jsonString)
        case let encodedComponent as SpecificEncodedComponent:
            return encodedComponent.encodedValue
        case let convertible as CustomStringConvertible:
            return encodeQueryComponent(convertible.description)
        default:
            return encodeQueryComponent("\(value)")
        }
    }

    private func encodeQueryComponent(_ component: String) -> String? {
        component.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
}
