import UIKit

public protocol MainTabBarCoordinatorDelegate: AnyObject {
    func mainTabBarCoordinatorDidFinish(_ coordinator: MainTabBarCoordinator)
}

public final class MainTabBarCoordinator {
    public var childCoordinators: [AnyObject] = []
    public let navigationController: UINavigationController
    public weak var delegate: MainTabBarCoordinatorDelegate?
    
    private var tabBarController: MainTabBarController?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let tabBarController = MainTabBarController()
        tabBarController.coordinator = self
        
        let homeNav = UINavigationController()
        homeNav.navigationBar.isHidden = true
        let homeCoordinator = HomeCoordinator(navigationController: homeNav)
        let homeVC = homeCoordinator.start()
        homeNav.setViewControllers([homeVC], animated: false)
        childCoordinators.append(homeCoordinator)
        
        let statisticsNav = UINavigationController()
        statisticsNav.navigationBar.isHidden = true
        let statisticsCoordinator = StatisticsCoordinator(navigationController: statisticsNav)
        let statisticsVC = statisticsCoordinator.start()
        statisticsNav.setViewControllers([statisticsVC], animated: false)
        childCoordinators.append(statisticsCoordinator)
        
        let playlistNav = UINavigationController()
        playlistNav.navigationBar.isHidden = true
        let playlistCoordinator = PlaylistCoordinator(navigationController: playlistNav)
        let playlistVC = playlistCoordinator.start()
        playlistNav.setViewControllers([playlistVC], animated: false)
        childCoordinators.append(playlistCoordinator)
        
        let settingsNav = UINavigationController()
        settingsNav.navigationBar.isHidden = true
        let settingsCoordinator = SettingsCoordinator(navigationController: settingsNav)
        let settingsVC = settingsCoordinator.start()
        settingsNav.setViewControllers([settingsVC], animated: false)
        childCoordinators.append(settingsCoordinator)
        
        tabBarController.setupViewControllers(
            homeNav: homeNav,
            statisticsNav: statisticsNav,
            playlistNav: playlistNav,
            settingsNav: settingsNav
        )
        
        self.tabBarController = tabBarController
        navigationController.setViewControllers([tabBarController], animated: true)
    }
    
    public func removeChild(_ child: AnyObject) {
        childCoordinators.removeAll { $0 === child }
    }
}