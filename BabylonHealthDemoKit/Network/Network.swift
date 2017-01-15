import Foundation
import ReactiveSwift
import Result

public enum NetworkError: Error {
    case noConnectivity
    case connectionFailed(ConnectionError)
}

public protocol NetworkProtocol {
    associatedtype Resource: ResourceProtocol

    func load(_ resource: Resource) -> SignalProducer<(Data, URLResponse), NetworkError>
}

public struct Network<Connection: ConnectionProtocol>: NetworkProtocol {
    public typealias Resource = Connection.Resource

    private let reachability: ReachabilityProtocol
    private let connection: Connection

    public init(connection: Connection, reachability: ReachabilityProtocol) {
        self.connection = connection
        self.reachability = reachability
    }

    public func load(_ resource: Resource) -> SignalProducer<(Data, URLResponse), NetworkError> {
        return validateConnectivity()
            .flatMapLatest {
                self.connection.load(resource)
                    .mapError(NetworkError.connectionFailed)
        }
    }

    func validateConnectivity() -> SignalProducer<Void, NetworkError> {
        return reachability.isReachable()
            .promoteErrors(NetworkError.self)
            .flatMapLatest { (isReachable) -> SignalProducer<Void, NetworkError> in
                return isReachable
                    ? SignalProducer(value: ())
                    : SignalProducer(error: .noConnectivity)
        }
    }
}
