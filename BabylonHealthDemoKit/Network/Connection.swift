import Foundation
import ReactiveSwift
import Result

public enum ConnectionError: Error {
    case invalidLocation
    case requestFailed(AnyError)
}

public protocol ConnectionProtocol {
    associatedtype Resource: ResourceProtocol

    func load(_ resource: Resource) -> SignalProducer<(Data, URLResponse), ConnectionError>
}

public struct HTTPConnection: ConnectionProtocol {

    private let baseURL: URL
    private let session: URLSession

    public init(baseURL: URL, session: URLSession) {
        self.baseURL = baseURL
        self.session = session
    }

    public func load(_ resource: HTTPResource) -> SignalProducer<(Data, URLResponse), ConnectionError> {
        return SignalProducer.attempt { self.generateURLRequest(for: resource) }
            .flatMapLatest(performRequest)
    }

    private func performRequest(request: URLRequest) -> SignalProducer<(Data, URLResponse), ConnectionError> {
        return session.reactive
            .data(with: request)
            .mapError(ConnectionError.requestFailed)
    }

    private func generateURLRequest(for resource: HTTPResource) -> Result<URLRequest, ConnectionError> {

        // NOTE: `URLComponents` has a bug and requires paths to start with "/" or an empty string, this
        // is an alternative which avoids that kind of checking
        guard let url = URL(string: resource.path, relativeTo: baseURL) else {
            return .failure(.invalidLocation)
        }

        guard var urlComponents = URLComponents(string: url.absoluteString) else {
            return .failure(.invalidLocation)
        }

        // Validate this to prevent an empty query, e.g. http://sample.com/something?
        urlComponents.queryItems = { $0.isEmpty ? nil : $0 }(resource.query.map(URLQueryItem.init))

        guard let generatedURL = urlComponents.url else {
            return .failure(.invalidLocation)
        }

        var request = URLRequest(url: generatedURL)
        request.httpMethod = resource.method.rawValue
        request.allHTTPHeaderFields = resource.headers
        
        return .success(request)
    }
}
