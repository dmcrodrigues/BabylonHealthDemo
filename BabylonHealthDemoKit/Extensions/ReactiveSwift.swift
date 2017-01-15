import Foundation
import ReactiveSwift
import enum Result.NoError

extension SignalProducerProtocol {

    public typealias Transform<U, E: Swift.Error> = (Value) -> SignalProducer<U, E>

    public func flatMapLatest<U>(_ transform: @escaping Transform<U, NoError>) -> SignalProducer<U, Error> {
        return flatMap(.latest, transform: transform)
    }

    public func flatMapLatest<U>(_ transform: @escaping Transform<U, Error>) -> SignalProducer<U, Error> {
        return flatMap(.latest, transform: transform)
    }
}
