import Foundation
import BabylonHealthDemoKit
import ReactiveSwift
import Result

struct PostViewModel {

    let title: Property<String>
}

struct PostsViewModel: LoadableResourceProtocol {

    private let posts = MutableProperty<[Post]>([])
    private let service: JSONPlaceholderServiceProtocol

    let action: Action<Void, [Post], ServiceError>

    let stateController: LoadableResourceStateController<Void, [Post], ServiceError>

    let postsCount: Property<Int>

    init(service s: JSONPlaceholderServiceProtocol) {
        service = s
        action = Action { s.posts() }
        stateController = LoadableResourceStateController(action)
        postsCount = posts.map { $0.count }

        posts <~ action.values
    }

    func postViewModel(at index: Int) -> PostViewModel {
        let post = posts.withValue { posts in
            return posts[index]
        }
        return PostViewModel(title: Property(value: post.title))
    }

    func postDetailsViewModel(at index: Int) -> PostDetailsViewModel {
        let post = posts.withValue { posts in
            return posts[index]
        }
        return PostDetailsViewModel(post: post, service: service)
    }
}
