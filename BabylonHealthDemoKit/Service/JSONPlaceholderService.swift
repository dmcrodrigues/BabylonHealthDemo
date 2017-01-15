import Foundation
import ReactiveSwift
import Result
import SQLite

enum JSONPlaceholderAPI: API {
    case users
    case user(User.Identifier)
    case posts
    case post(Post.Identifier)
    case postComments(Post.Identifier)
    case comments

    var path: String {
        switch self {
        case .users:
            return "users"
        case .user(let userId):
            return JSONPlaceholderAPI.users.path.ns.appendingPathComponent(String(describing: userId))
        case .posts:
            return "posts"
        case .post(let postId):
            return JSONPlaceholderAPI.posts.path.ns.appendingPathComponent(String(describing: postId))
        case .postComments(let postId):
            return JSONPlaceholderAPI.post(postId).path.ns.appendingPathComponent("/comments")
        case .comments:
            return "comments"
        }
    }

    var query: [String : String] {
        return [:]
    }

    var resource: HTTPResource {
        return HTTPResource(path: path, method: .GET, query: [:], headers: [:], body: nil)
    }
}

public enum JSONPlaceholderServiceError: Error {
    case requestFailed
    case parsingFailed
    case persistenceFailed
}

public protocol JSONPlaceholderServiceProtocol {

    func posts() -> SignalProducer<[Post], ServiceError>

    func comments() -> SignalProducer<[Comment], ServiceError>

    func users() -> SignalProducer<[User], ServiceError>

    func user(userId: User.Identifier) -> SignalProducer<User, ServiceError>

    func postComments(postId: Post.Identifier) -> SignalProducer<[Comment], ServiceError>
}

public struct JSONPlaceholderService<Network: NetworkProtocol>: JSONPlaceholderServiceProtocol, Service
    where Network.Resource == HTTPResource
{

    let network: Network
    let parser: Parser

    private let postsRepository: PostsRepository
    private let usersRepository: UsersRepository
    private let commentsRepository: CommentsRepository

    public init(
        network: Network,
        parser: Parser,
        postsRepository: PostsRepository,
        usersRepository: UsersRepository,
        commentsRepository: CommentsRepository)
    {
        self.network = network
        self.parser = parser
        self.postsRepository = postsRepository
        self.usersRepository = usersRepository
        self.commentsRepository = commentsRepository
    }

    // NOTE: This implementations should be ideally defined and reused in a single flow

    public func posts() -> SignalProducer<[Post], ServiceError> {
        return fetch(JSONPlaceholderAPI.posts)
            .flatMapError { _ in
                self.postsRepository.fetch()
                    .mapError { _ in ServiceError.requestFailed }
            }
            .flatMapLatest {
                self.postsRepository.createOrUpdate(elements: $0)
                    .mapError { _ in ServiceError.persistFailed } }
    }

    public func users() -> SignalProducer<[User], ServiceError> {
        return fetch(JSONPlaceholderAPI.users)
            .flatMapError { _ in
                self.usersRepository.fetch()
                    .mapError { _ in ServiceError.requestFailed }
            }
            .flatMapLatest {
                self.usersRepository.createOrUpdate(elements: $0)
                    .mapError { _ in ServiceError.persistFailed } }
    }

    public func comments() -> SignalProducer<[Comment], ServiceError> {
        return fetch(JSONPlaceholderAPI.comments)
            .flatMapError { _ in
                self.commentsRepository.fetch()
                    .mapError { _ in ServiceError.requestFailed }
            }
            .flatMapLatest {
                self.commentsRepository.createOrUpdate(elements: $0)
                    .mapError { _ in ServiceError.persistFailed } }
    }

    public func user(userId: User.Identifier) -> SignalProducer<User, ServiceError> {
        return fetch(JSONPlaceholderAPI.user(userId))
            .flatMapError { _ in
                self.usersRepository.fetch(userId)
                    .mapError { _ in ServiceError.requestFailed }
            }
            .flatMapLatest {
                self.usersRepository.createOrUpdate(element: $0)
                    .mapError { _ in ServiceError.persistFailed }
        }
    }

    public func postComments(postId: Post.Identifier) -> SignalProducer<[Comment], ServiceError> {
        return fetch(JSONPlaceholderAPI.postComments(postId))
            .flatMapError { _ in
                // This should somehow improved otherwise we are leaking implementation details here...
                self.commentsRepository.fetch(where: CommentsTable.postId == postId)
                    .mapError { _ in ServiceError.requestFailed }
            }
            .flatMapLatest {
                self.commentsRepository.createOrUpdate(elements: $0)
                    .mapError { _ in ServiceError.persistFailed }
        }
    }
}

// MARK: - Convenience helper

fileprivate extension String {

    fileprivate var ns: NSString {
        return self as NSString
    }
}
