import UIKit

enum Segue {
    case openPostDetails(PostDetailsViewModel)

    var identifier: String {
        return "openPostDetails"
    }

    func injectDependencies(in instance: DependencyInjectable) {
        switch self {
        case let .openPostDetails(viewModel):
            let container = PostDetailsDependencyContainer(viewModel: viewModel)
            instance.injectDependencies(from: container)
        }
    }
}

protocol DependencyContainer {}

protocol DependencyInjectable {

    func injectDependencies(from container: DependencyContainer)
}

extension UIViewController {

    func perform(segue: Segue, sender: Any?) {
        reactive
            .signal(for: #selector(prepare(for:sender:)))
            .take(first: 1)
            .observeValues { parameters in
                guard let destination = (parameters.first as? UIStoryboardSegue)?.destination as? DependencyInjectable else { return }
                segue.injectDependencies(in: destination)
        }

        performSegue(withIdentifier: segue.identifier, sender: sender)
    }
}
