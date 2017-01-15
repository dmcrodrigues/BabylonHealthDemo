import Foundation
import Result

public struct User {
    public let id: Int64
    public let name: String
    public let username: String
    public let email: String
    public let phone: String
    public let website: String
    public let address: Address
}

extension User: JSONParsable {

    public static func parse(_ json: JSON) -> Result<User, ParseError> {
        guard
            let id = json["id"] as? Int64,
            let name = json["name"] as? String,
            let username = json["username"] as? String,
            let email = json["email"] as? String,
            let phone = json["phone"] as? String,
            let website = json["website"] as? String,
            let addressJSON = json["address"] as? JSON,
            let address = Address.parse(addressJSON).value
            else { return .failure(.invalidData) }

        return .success(
            User(id: id,
                 name: name,
                 username: username,
                 email: email,
                 phone: phone,
                 website: website,
                 address: address))
    }
}
