import Foundation
import ReactiveSwift
import enum Result.Result
import struct Result.AnyError
import SQLite

public enum RepositoryError: Error {
    case persistenceFailed
    case notFound
}

protocol Repository {
    associatedtype Element: Persistable

    var db: SQLite.Connection { get }

    func fetch() -> SignalProducer<[Element], RepositoryError>

    func fetch(_ elementId: Element.Identifier) -> SignalProducer<Element, RepositoryError>

    func createOrUpdate(element: Element) -> SignalProducer<Element, RepositoryError>

    func createOrUpdate(elements: [Element]) -> SignalProducer<[Element], RepositoryError>
}

extension Repository {

    fileprivate func fetch(with table: Table) -> Result<[Element], AnyError> {
        return Result {
            return try self.db.prepare(table).map(Element.decode)
        }
    }

    func createOrUpdate(element: Element) -> SignalProducer<Element, RepositoryError> {
        return createOrUpdate(elements: [element])
            .attemptMap { elements in
                guard elements.count == 1 else {
                    return .failure(RepositoryError.persistenceFailed)
                }
                return .success(elements[0])
        }

    }
}

public struct PostsRepository: Repository {
    typealias Element = Post

    let db: SQLite.Connection

    public init?(db: SQLite.Connection) {
        self.db = db
        guard case .success = PostsTable.create(in: db) else { return nil }
    }

    func fetch() -> SignalProducer<[Post], RepositoryError> {
        return SignalProducer.attempt {
            self.fetch(with: PostsTable.posts)
                .mapError { _ in .persistenceFailed }
        }
    }

    func fetch(_ elementId: Element.Identifier) -> SignalProducer<Post, RepositoryError> {
        return SignalProducer.attempt {
            self.fetch(with: PostsTable.posts.filter(PostsTable.id == elementId))
                .mapError { _ in .persistenceFailed }
                .flatMap {
                    guard let post = $0.first else {
                        return .failure(.notFound)
                    }
                    return .success(post)
            }
        }
    }

    public func createOrUpdate(elements: [Post]) -> SignalProducer<[Post], RepositoryError> {
        return SignalProducer { observer, _ in
            do {
                try self.db.transaction {
                    try elements.forEach { post in
                        try self.db.run(PostsTable.posts.insert(or: .replace,
                                                                PostsTable.id       <- post.id,
                                                                PostsTable.userId   <- post.userId,
                                                                PostsTable.title    <- post.title,
                                                                PostsTable.body     <- post.body)
                        )
                    }
                }
                observer.send(value: elements)
                observer.sendCompleted()
            } catch {
                observer.send(error: .persistenceFailed)
            }
        }
    }
}

public struct UsersRepository: Repository {
    typealias Element = User

    let db: SQLite.Connection

    public init?(db: SQLite.Connection) {
        self.db = db
        guard case .success = UsersTable.create(in: db) else { return nil }
    }

    func fetch() -> SignalProducer<[User], RepositoryError> {
        return SignalProducer.attempt {
            self.fetch(with: UsersTable.users)
                .mapError { _ in .persistenceFailed }
        }
    }

    func fetch(_ elementId: Element.Identifier) -> SignalProducer<User, RepositoryError> {
        return SignalProducer.attempt {
            self.fetch(with: UsersTable.users.filter(UsersTable.id == elementId))
                .mapError { _ in .persistenceFailed }
                .flatMap {
                    guard let user = $0.first else {
                        return .failure(.notFound)
                    }
                    return .success(user)
            }
        }
    }

    public func createOrUpdate(elements: [User]) -> SignalProducer<[User], RepositoryError> {
        return SignalProducer { observer, _ in
            do {
                try self.db.transaction {
                    try elements.forEach { user in
                        try self.db.run(UsersTable.users.insert(or: .replace,
                                                                UsersTable.id       <- user.id,
                                                                UsersTable.name     <- user.name,
                                                                UsersTable.username <- user.username,
                                                                UsersTable.email    <- user.email,
                                                                UsersTable.phone    <- user.phone,
                                                                UsersTable.website  <- user.website,
                                                                UsersTable.street   <- user.address.street,
                                                                UsersTable.suite    <- user.address.suite,
                                                                UsersTable.city     <- user.address.city,
                                                                UsersTable.zipCode  <- user.address.zipCode)
                        )
                    }
                }
                observer.send(value: elements)
                observer.sendCompleted()
            } catch {
                observer.send(error: .persistenceFailed)
            }
        }
    }
}

public struct CommentsRepository: Repository {
    typealias Element = Comment

    let db: SQLite.Connection

    public init?(db: SQLite.Connection) {
        self.db = db
        guard case .success = CommentsTable.create(in: db) else { return nil }
    }

    func fetch() -> SignalProducer<[Element], RepositoryError> {
        return SignalProducer.attempt {
            self.fetch(with: CommentsTable.comments)
                .mapError { _ in .persistenceFailed }
        }
    }

    func fetch(_ elementId: Element.Identifier) -> SignalProducer<Comment, RepositoryError> {
        return SignalProducer.attempt {
            self.fetch(with: CommentsTable.comments.filter(CommentsTable.id == elementId))
                .mapError { _ in .persistenceFailed }
                .flatMap {
                    guard let comment = $0.first else {
                        return .failure(.notFound)
                    }
                    return .success(comment)
            }
        }
    }

    func fetch(where expression: Expression<Bool>) -> SignalProducer<[Comment], RepositoryError> {
        return SignalProducer.attempt {
            self.fetch(with: CommentsTable.comments.filter(expression))
                .mapError { _ in .persistenceFailed }
        }
    }

    public func createOrUpdate(elements: [Comment]) -> SignalProducer<[Comment], RepositoryError> {
        return SignalProducer { observer, _ in
            do {
                try self.db.transaction {
                    try elements.forEach { comment in
                        try self.db.run(CommentsTable.comments.insert(or: .replace,
                                                                CommentsTable.id        <- comment.id,
                                                                CommentsTable.postId    <- comment.postId,
                                                                CommentsTable.name      <- comment.name,
                                                                CommentsTable.email     <- comment.email,
                                                                CommentsTable.body      <- comment.body)
                        )
                    }
                }
                observer.send(value: elements)
                observer.sendCompleted()
            } catch {
                observer.send(error: .persistenceFailed)
            }
        }
    }
}
