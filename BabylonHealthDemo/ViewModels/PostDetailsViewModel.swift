import Foundation
import BabylonHealthDemoKit
import ReactiveSwift

struct PostDetailsViewModel: LoadableResourceProtocol {

    private let post: Post
    private let service: JSONPlaceholderServiceProtocol

    typealias Value = (Post, User, [Comment])

    let action: Action<Void, Value, ServiceError>

    let stateController: LoadableResourceStateController<Void, Value, ServiceError>

    let author: Property<String>
    let description: Property<String>
    let commentsDescription: Property<String>

    init(post: Post, service: JSONPlaceholderServiceProtocol) {
        self.post = post
        self.service = service

        self.action = Action {
            SignalProducer.combineLatest(
                SignalProducer(value: post),
                service.user(userId: post.userId),
                service.postComments(postId: post.id)
            )
        }

        author = Property(initial: "", then: action.values.map { $0.1.name })
        description = Property(initial: "", then: action.values.map { $0.0.body })
        commentsDescription = Property(
            initial: "",
            then: action.values.map { String(format: localized("post_details.comments.section.text"), $0.2.count)})

        self.stateController = LoadableResourceStateController(action)
    }
}
