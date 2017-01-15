import Foundation
import Result

public enum ParseError: Error {
    case invalidData
}

public protocol Parsable {
    associatedtype Payload

    static func parse(_ payload: Payload) -> Result<Self, ParseError>
}

public typealias JSON = [String : Any]

public protocol JSONParsable: Parsable {
    typealias Payload = JSON
}
