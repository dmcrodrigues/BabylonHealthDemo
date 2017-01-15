import Foundation
import Result

public struct Address {
    public let street: String
    public let suite: String
    public let city: String
    public let zipCode: String
}

extension Address: JSONParsable {

    public static func parse(_ json: JSON) -> Result<Address, ParseError> {
        guard
            let street = json["street"] as? String,
            let suite = json["suite"] as? String,
            let city = json["city"] as? String,
            let zipCode = json["zipcode"] as? String
            else { return .failure(.invalidData) }

        return .success(Address(street: street, suite: suite, city: city, zipCode: zipCode))
    }
}
