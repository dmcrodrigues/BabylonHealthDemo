import Foundation
import ReactiveSwift
import Result

public struct Preheater {

    private let service: JSONPlaceholderServiceProtocol
    private let disposable: Atomic<Disposable?>
    private let scheduler: QueueScheduler

    public init(service: JSONPlaceholderServiceProtocol) {
        self.service = service
        self.disposable = Atomic(nil)
        self.scheduler = QueueScheduler(qos: .background,
                                        name: "com.dmcrodrigues.BabylonHealthDemoKit.Preheater",
                                        targeting: nil)
    }

    public func start() {
        disposable.modify { disposable -> Bool in
            guard disposable == nil else { return false }

            disposable = SignalProducer(value: ())
                .concat(enteringForeground())
                .observe(on: scheduler)
                .map { _ in }
                .flatMap(.latest, transform: loadData)
                .start()

            return true
        }
    }

    public func stop() {
        disposable.modify { disposable in
            guard disposable != nil else { return }
            disposable?.dispose()
            disposable = nil
        }
    }

    private func enteringForeground() -> SignalProducer<Void, NoError> {
        let signal = NotificationCenter.default.reactive
            .notifications(forName: .UIApplicationWillEnterForeground)
            .map { _ in }
        return SignalProducer(signal)
    }

    private func loadData() -> SignalProducer<Void, NoError> {
        return SignalProducer.combineLatest(
            service.posts(),
            service.users(),
            service.comments()
            )
            .observe(on: scheduler)
            .map { _ in }
            .flatMapError { _ in .empty }
    }
}
