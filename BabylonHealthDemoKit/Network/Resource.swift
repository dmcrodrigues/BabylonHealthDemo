import Foundation
import Result

public enum Method: String { // REST Methods
    case GET
    case POST
    case PUT
    case PATCH
    case DELETE
}

public protocol ResourceProtocol {
    var location: String { get }
}

public protocol HTTPResourceProtocol: ResourceProtocol {
    var method: Method { get }
    var query: [String : String] { get }
    var headers: [String : String] { get }
    var body: Data? { get }

    // This could be added in the future to validate if a certain resource 
    // requires a secure connection (HTTPS) or not (HTTP)
    // var secure: Bool { get }

    // This could be added in the future to validate an error if needed
    // var statusCodeValid: (Int) -> Bool { get }
}

public struct HTTPResource: HTTPResourceProtocol {

    public let path: String
    public let method: Method
    public let query: [String : String]
    public let headers: [String : String]
    public let body: Data?

    public var location: String {
        return path
    }
}
