import UIKit

public protocol SplashCoordinatorDelegate: AnyObject {
    func splashCoordinatorDidFinish(_ coordinator: SplashCoordinator)
}

public final class SplashCoordinator {
    public let navigationController: UINavigationController
    public weak var delegate: SplashCoordinatorDelegate?
    public var childCoordinators: [AnyObject] = []

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    public func start() {
        let splashViewController = SplashViewController()
        splashViewController.coordinator = self
        navigationController.setViewControllers([splashViewController], animated: false)
    }

    public func routeToOnboarding() {
        delegate?.splashCoordinatorDidFinish(self)
    }

    public func removeChild(_ child: AnyObject) {
        childCoordinators.removeAll { $0 === child }
    }
}
