import UIKit

public protocol OnboardingCoordinatorDelegate: AnyObject {
    func onboardingCoordinatorDidFinish(_ coordinator: OnboardingCoordinator)
}

public final class OnboardingCoordinator {
    public var childCoordinators: [AnyObject] = []
    public let navigationController: UINavigationController
    public weak var delegate: OnboardingCoordinatorDelegate?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let onboardingReactor = OnboardingReactor(coordinator: self)
        let onboardingVC = OnboardingViewController(reactor: onboardingReactor)
        onboardingVC.coordinator = self
        navigationController.setViewControllers([onboardingVC], animated: false)
    }
    
    public func showSignIn() {
        let signInCoordinator = SignInCoordinator(navigationController: navigationController)
        signInCoordinator.delegate = self
        childCoordinators.append(signInCoordinator)
        signInCoordinator.start()
    }
    
    public func showMainTab() {
        let mainTabCoordinator = MainTabBarCoordinator(navigationController: navigationController)
        mainTabCoordinator.delegate = self
        childCoordinators.append(mainTabCoordinator)
        mainTabCoordinator.start()
    }
    
    public func removeChild(_ child: AnyObject) {
        childCoordinators.removeAll { $0 === child }
    }
}

extension OnboardingCoordinator: SignInCoordinatorDelegate {
    public func signInCoordinatorDidFinish(_ coordinator: SignInCoordinator) {
        removeChild(coordinator)
    }
}

extension OnboardingCoordinator: MainTabBarCoordinatorDelegate {
    public func mainTabBarCoordinatorDidFinish(_ coordinator: MainTabBarCoordinator) {
        removeChild(coordinator)
    }
}