import UIKit
import BabylonHealthDemoKit
import ReactiveSwift
import ReactiveCocoa

class PostsViewController: UIViewController {

    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    var viewModel: PostsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = localized("posts.title");

        tableView.refreshControl = {
            $0.reactive.refresh = CocoaAction(viewModel.action)
            return $0
        }(UIRefreshControl())

        viewModel.stateController.state
            .signal
            .observe(on: UIScheduler())
            .observeValues { [weak self] state in
                self?.update(to: state)
        }

        viewModel.fetch()
    }

    func update(to state: LoadableResourceState<[Post], ServiceError>) {
        switch state {
        case .waiting, .loading:
            // refresh control already watches this state through action...
            break
        case .failed(_):
            // Present some error...
            break
        case .loaded(_):
            self.tableView.reloadData()
        }
    }
}

extension PostsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.perform(segue: .openPostDetails(viewModel.postDetailsViewModel(at: indexPath.row)), sender: nil)
    }
}

extension PostsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.postsCount.value
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel.postViewModel(at: indexPath.row)

        let cell: PostTableViewCell = tableView.reusableCell(for: indexPath)
        cell.titleLabel.reactive.text <~ cellViewModel.title
        return cell
    }
}
