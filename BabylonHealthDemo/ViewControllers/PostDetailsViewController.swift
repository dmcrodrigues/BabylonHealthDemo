import UIKit
import ReactiveSwift
import ReactiveCocoa
import BabylonHealthDemoKit

class PostDetailsViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView! {
        didSet {
            descriptionTextView.textContainer.lineBreakMode = .byTruncatingTail
            descriptionTextView.textContainer.lineFragmentPadding = 0
        }
    }

    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    var viewModel: PostDetailsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = localized("post_details.title");

        viewModel.stateController.state
            .signal
            .observe(on: UIScheduler())
            .observeValues { [weak self] state in
                self?.update(to: state)
        }

        viewModel.fetch()
    }

    func update(to state: LoadableResourceState<PostDetailsViewModel.Value, ServiceError>) {
        switch state {
        case .waiting, .loading:
            // Loading already in place...
            break
        case .failed(_):
            // Present some error...
            break
        case .loaded(_):
            UIView.animate(withDuration: 0.4) {
                self.authorLabel.reactive.text <~ self.viewModel.author
                self.descriptionTextView.reactive.text <~ self.viewModel.description
                self.commentsLabel.reactive.text <~ self.viewModel.commentsDescription

                [ self.authorLabel, self.descriptionTextView, self.commentsLabel]
                    .forEach { $0.isHidden = false }

                self.stackView.removeArrangedSubview(self.activityIndicatorView)
            }
        }
    }

}

struct PostDetailsDependencyContainer: DependencyContainer {
    let viewModel: PostDetailsViewModel
}

extension PostDetailsViewController: DependencyInjectable {

    func injectDependencies(from container: DependencyContainer) {
        guard let container = container as? PostDetailsDependencyContainer else { return }

        viewModel = container.viewModel
    }
}
