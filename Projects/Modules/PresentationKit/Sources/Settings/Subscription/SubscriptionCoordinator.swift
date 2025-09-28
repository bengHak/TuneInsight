import UIKit

public protocol SubscriptionCoordinatorDelegate: AnyObject {
    func subscriptionCoordinatorDidFinish(_ coordinator: SubscriptionCoordinator)
}

public final class SubscriptionCoordinator {
    public var childCoordinators: [AnyObject] = []
    public let navigationController: UINavigationController
    public weak var delegate: SubscriptionCoordinatorDelegate?

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    public func start() -> UIViewController {
        let vc = SubscriptionViewController()
        return vc
    }

    public func removeChild(_ child: AnyObject) {
        childCoordinators.removeAll { $0 === child }
    }
}

