import Foundation
import SQLite

public protocol Identifiable {
    associatedtype Identifier: Equatable

    var id: Identifier { get }
}

protocol Persistable: Identifiable {

    static func decode(row: Row) -> Self
}

extension Post: Persistable {
    public typealias Identifier = Int64

    static func decode(row: Row) -> Post {
        return Post(id:     row[PostsTable.id],
                    userId: row[PostsTable.userId],
                    title:  row[PostsTable.title],
                    body:   row[PostsTable.body])
    }
}

extension User: Persistable {
    public typealias Identifier = Int64

    static func decode(row: Row) -> User {

        let address = Address(street:   row[UsersTable.street],
                              suite:    row[UsersTable.suite],
                              city:     row[UsersTable.city],
                              zipCode:  row[UsersTable.zipCode])

        return User(id:         row[UsersTable.id],
                    name:       row[UsersTable.name],
                    username:   row[UsersTable.username],
                    email:      row[UsersTable.email],
                    phone:      row[UsersTable.phone],
                    website:    row[UsersTable.website],
                    address:    address)
    }
}

extension Comment: Persistable {
    public typealias Identifier = Int64

    static func decode(row: Row) -> Comment {
        return Comment(id:  row[CommentsTable.id],
                    postId: row[CommentsTable.postId],
                    name:   row[CommentsTable.name],
                    email:  row[CommentsTable.email],
                    body:   row[CommentsTable.body])
    }
}
