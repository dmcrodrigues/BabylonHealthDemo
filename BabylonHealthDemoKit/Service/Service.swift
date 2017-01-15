import Foundation
import ReactiveSwift

public protocol API {
    associatedtype Resource: ResourceProtocol

    var resource: Resource { get }
}

public enum ServiceError: Error {
    case offline
    case requestFailed
    case parseFailed
    case persistFailed
}

protocol Service {
    associatedtype Network: NetworkProtocol

    var network: Network { get }
    var parser: Parser { get }
}

extension Service {

    func fetch<Endpoint, T>(_ endpoint: Endpoint) -> SignalProducer<T, ServiceError>
        where Endpoint: API, T: Parsable, Network.Resource == Endpoint.Resource
    {
        return request(endpoint.resource)
            .flatMapLatest(parse)
    }

    // NOTE: Necessary until generics are completed (Swift 4 🤞)
    func fetch<Endpoint, T>(_ endpoint: Endpoint) -> SignalProducer<[T], ServiceError>
        where Endpoint: API, T: Parsable, Network.Resource == Endpoint.Resource
    {
        return request(endpoint.resource)
            .flatMapLatest(parse)
    }

    // MARK: - Helpers

    private func request(_ resource: Network.Resource) -> SignalProducer<Data, ServiceError> {
        return network.load(resource)
            .mapError { _ in .requestFailed }
            .map { $0.0 }
    }

    private func parse<T: Parsable>(data: Data) -> SignalProducer<T, ServiceError> {
        return self.parser.parse(data)
            .mapError { _ in .parseFailed }
    }

    // NOTE: Necessary until generics are completed (Swift 4 🤞)
    private func parse<T: Parsable>(data: Data) -> SignalProducer<[T], ServiceError> {
        return self.parser.parse(data)
            .mapError { _ in .parseFailed }
    }
}
