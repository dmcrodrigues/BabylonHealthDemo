import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    lazy var bootstrapper = Bootstrapper()

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey : Any]? = nil)
        -> Bool
    {
        window = UIWindow(frame: UIScreen.main.bounds)

        // Well, now I know I shouldn't have used storyboards in the first place...
        self.window?.rootViewController = { () -> UIViewController in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
            let postViewController = navigationController.topViewController as! PostsViewController
            postViewController.viewModel = PostsViewModel(service: bootstrapper.service)
            return navigationController
        }()

        self.window?.makeKeyAndVisible()

        return true
    }
}

