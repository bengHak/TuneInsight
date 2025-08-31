import UIKit

protocol SplashCoordinatorDelegate: AnyObject {
    func splashCoordinatorDidFinish(_ coordinator: SplashCoordinator)
}

final class SplashCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    private weak var parentCoordinator: AppCoordinator?
    
    init(navigationController: UINavigationController, parentCoordinator: AppCoordinator) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
    }
    
    func start() {
        let splashVC = SplashViewController()
        splashVC.coordinator = self
        navigationController.setViewControllers([splashVC], animated: false)
    }
    
    func routeToOnboarding() {
        parentCoordinator?.removeChild(self)
        parentCoordinator?.showOnboarding()
    }
}