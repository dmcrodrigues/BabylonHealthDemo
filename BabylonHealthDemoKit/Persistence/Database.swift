import SQLite
import enum Result.Result
import struct Result.AnyError

struct PostsTable {

    static let posts = SQLite.Table("posts")

    static let id = Expression<Int64>("id")
    static let userId = Expression<Int64>("userId")
    static let title = Expression<String>("title")
    static let body = Expression<String>("body")

    static func create(in db: SQLite.Connection) -> Result<Void, AnyError> {
        return Result {
            try db.run(posts.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(userId)
                t.column(title)
                t.column(body)
                t.foreignKey(userId, references: UsersTable.users, UsersTable.id)
            })
        }
    }
}

struct UsersTable {

    static let users = SQLite.Table("users")

    static let id = Expression<Int64>("id")
    static let name = Expression<String>("name")
    static let username = Expression<String>("username")
    static let email = Expression<String>("email")
    static let phone = Expression<String>("phone")
    static let website = Expression<String>("website")

    // Address
    static let street = Expression<String>("street")
    static let suite = Expression<String>("suite")
    static let city = Expression<String>("city")
    static let zipCode = Expression<String>("zipCode")

    static func create(in db: SQLite.Connection) -> Result<Void, AnyError> {
        return Result {
            try db.run(users.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(name)
                t.column(username)
                t.column(email)
                t.column(phone)
                t.column(website)
                t.column(street)
                t.column(suite)
                t.column(city)
                t.column(zipCode)
            })
            
        }
    }
}

struct CommentsTable {

    static let comments = SQLite.Table("comments")

    static let id = Expression<Int64>("id")
    static let postId = Expression<Int64>("postId")
    static let name = Expression<String>("name")
    static let email = Expression<String>("email")
    static let body = Expression<String>("body")

    static func create(in db: SQLite.Connection) -> Result<Void, AnyError> {
        return Result {
            try db.run(comments.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(postId)
                t.column(name)
                t.column(email)
                t.column(body)
                t.foreignKey(postId, references: PostsTable.posts, PostsTable.id)
            })

        }
    }
}
