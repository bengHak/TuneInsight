import UIKit
import PresentationKit

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var presentationCoordinators: [AnyObject] = []
    let navigationController: UINavigationController
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
        self.navigationController.navigationBar.isHidden = true
    }
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        showSplash()
    }
    
    private func showSplash() {
        let splashCoordinator = SplashCoordinator(
            navigationController: navigationController,
            parentCoordinator: self
        )
        addChild(splashCoordinator)
        splashCoordinator.start()
    }
    
    func showOnboarding() {
        let onboardingCoordinator = OnboardingCoordinator(
            navigationController: navigationController
        )
        onboardingCoordinator.delegate = self
        presentationCoordinators.append(onboardingCoordinator)
        onboardingCoordinator.start()
    }
    
    func removePresentationChild(_ child: AnyObject) {
        presentationCoordinators.removeAll { $0 === child }
    }
}

extension AppCoordinator: OnboardingCoordinatorDelegate {
    func onboardingCoordinatorDidFinish(_ coordinator: OnboardingCoordinator) {
        removePresentationChild(coordinator)
    }
}