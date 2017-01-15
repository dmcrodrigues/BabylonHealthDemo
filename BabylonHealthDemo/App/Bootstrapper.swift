import Foundation
import BabylonHealthDemoKit
import SQLite

struct Bootstrapper {

    let connection: HTTPConnection
    let reachability: ReachabilityProtocol
    let network: Network<HTTPConnection>
    let parser: Parser
    let service: JSONPlaceholderServiceProtocol
    let preheater: Preheater

    let postsRepository: PostsRepository
    let usersRepository: UsersRepository
    let commentsRepository: CommentsRepository

    init() {
        connection = HTTPConnection(
            baseURL: URL(string: "https://jsonplaceholder.typicode.com")!,
            session: URLSession.shared
        )
        reachability = Reachability()
        network = Network(connection: connection, reachability: reachability)
        parser = JSONParser()

        (postsRepository, usersRepository, commentsRepository) = setUpDatabase()

        service = JSONPlaceholderService(
            network: network,
            parser: parser,
            postsRepository: postsRepository,
            usersRepository: usersRepository,
            commentsRepository: commentsRepository)

        preheater = Preheater(service: service)
        preheater.start()
    }
}

func setUpDatabase() -> (PostsRepository, UsersRepository, CommentsRepository) {
    guard let db = try? SQLite.Connection("\(FileManager.documentsDirectory())/database.sqlite3") else {
        fatalError("💥 Unable to connect to database")
    }

    guard
        let postsRepository = PostsRepository(db: db),
        let usersRepository = UsersRepository(db: db),
        let commentsRepository = CommentsRepository(db: db)
        else { fatalError("💥 Unable to set up repositories") }

    return (postsRepository, usersRepository, commentsRepository)
}
