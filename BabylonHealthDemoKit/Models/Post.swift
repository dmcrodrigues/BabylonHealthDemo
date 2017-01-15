import Foundation
import Result

public struct Post {
    public let id: Int64
    public let userId: Int64
    public let title: String
    public let body: String
}

extension Post: JSONParsable {

    public static func parse(_ json: JSON) -> Result<Post, ParseError> {
        guard
            let id = json["id"] as? Int64,
            let userId = json["userId"] as? Int64,
            let title = json["title"] as? String,
            let body = json["body"] as? String
            else { return .failure(.invalidData) }

        return .success(Post(id: id, userId: userId, title: title, body: body))
    }
}
