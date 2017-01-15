import Foundation
import ReactiveSwift
import Result

public enum ParserError: Error {
    case parsingFailed
}

public protocol Parser {

    func parse<T: Parsable>(_ data: Data) -> SignalProducer<T, ServiceError>

    // NOTE: Necessary until generics are completed (Swift 4 🤞)
    func parse<T: Parsable>(_ data: Data) -> SignalProducer<[T], ServiceError>
}

public struct JSONParser: Parser {

    public init() {}

    public func parse<T: Parsable>(_ data: Data) -> SignalProducer<T, ServiceError> {
        return decode(data)
            .mapError { _ in ServiceError.parseFailed }
            .flatMapLatest(parseObject)
    }

    // NOTE: Necessary until generics are completed (Swift 4 🤞)
    public func parse<T: Parsable>(_ data: Data) -> SignalProducer<[T], ServiceError> {
        return decode(data)
            .mapError { _ in ServiceError.parseFailed }
            .flatMapLatest(parseArray)
    }

    public func decode<T>(_ data: Data) -> SignalProducer<T, ParserError> {
        return SignalProducer.attempt {
            return Result {
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? T else {
                    throw ParserError.parsingFailed
                }
                return jsonObject
            }
        }
    }

    private func parseObject<T: Parsable>(_ json: T.Payload) -> SignalProducer<T, ServiceError> {
        return SignalProducer.attempt { T.parse(json) }
            .mapError { _ in ServiceError.parseFailed }
    }

    // NOTE: Necessary until generics are completed (Swift 4 🤞)
    private func parseArray<T: Parsable>(_ json: [T.Payload]) -> SignalProducer<[T], ServiceError> {
        return SignalProducer(json)
            .flatMapLatest( parseObject)
            .collect()
    }
}
