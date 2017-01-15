import Foundation
import Result

public struct Comment {
    public let id: Int64
    public let postId: Int64
    public let name: String
    public let email: String
    public let body: String
}

extension Comment: JSONParsable {

    public static func parse(_ json: JSON) -> Result<Comment, ParseError> {
        guard
            let id = json["id"] as? Int64,
            let postId = json["postId"] as? Int64,
            let name = json["name"] as? String,
            let email = json["email"] as? String,
            let body = json["body"] as? String
            else { return .failure(.invalidData) }

        return .success(Comment(id: id, postId: postId, name: name, email: email, body: body))
    }
}
