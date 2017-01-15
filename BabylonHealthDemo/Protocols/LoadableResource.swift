import Foundation
import ReactiveSwift
import Result

enum LoadableResourceError: Error {
    case requestFailed(AnyError)
}

enum LoadableResourceState<T, E: Error> {
    case waiting
    case loading
    case loaded(T)
    case failed(E)
}

struct LoadableResourceStateController<Input, Resource, E: Error> {

    let state: Property<LoadableResourceState<Resource, E>>

    init(_ state: Property<LoadableResourceState<Resource, E>>) {
        self.state = state
    }

    init(_ action: Action<Input, Resource, E>) {
        let state = MutableProperty<LoadableResourceState<Resource, E>>(.waiting)
        state <~ action.isExecuting.producer.filter { $0 }.map { _ in .loading }
        state <~ action.values.map(LoadableResourceState.loaded)
        state <~ action.errors.map(LoadableResourceState.failed)
        self.init(Property(capturing: state))
    }
}

protocol LoadableResourceProtocol {
    associatedtype Input
    associatedtype Resource
    associatedtype E: Error

    var stateController: LoadableResourceStateController<Input, Resource, E> { get }

    var action: Action<Input, Resource, E> { get }

    func fetch(_ input: Input)
}

extension LoadableResourceProtocol {

    func fetch(_ input: Input) {
        action.apply(input).start()
    }
}
