import UIKit
import DIKit
import DomainKit

public protocol MainTabBarCoordinatorDelegate: AnyObject {
    func mainTabBarCoordinatorDidFinish(_ coordinator: MainTabBarCoordinator)
    func mainTabBarCoordinatorDidLogout(_ coordinator: MainTabBarCoordinator)
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
        let homeCoordinator = HomeCoordinator(navigationController: homeNav)
        let homeVC = homeCoordinator.start()
        homeVC.navigationItem.largeTitleDisplayMode = .inline
        homeNav.setViewControllers([homeVC], animated: false)
        childCoordinators.append(homeCoordinator)
        
        let statisticsNav = UINavigationController()
        let statisticsCoordinator = StatisticsCoordinator(navigationController: statisticsNav)
        let statisticsVC = statisticsCoordinator.start()
        statisticsVC.navigationItem.largeTitleDisplayMode = .inline
        statisticsNav.setViewControllers([statisticsVC], animated: false)
        childCoordinators.append(statisticsCoordinator)
        
        let playlistNav = UINavigationController()
        // For now, create PlaylistCoordinator manually - will add proper DI later
        let playlistCoordinator = PlaylistCoordinator(
            navigationController: playlistNav,
            getUserPlaylistsUseCase: DIContainer.shared.resolve(GetUserPlaylistsUseCaseProtocol.self)!,
            createPlaylistUseCase: DIContainer.shared.resolve(CreatePlaylistUseCaseProtocol.self)!,
            deletePlaylistUseCase: DIContainer.shared.resolve(DeletePlaylistUseCaseProtocol.self)!,
            getPlaylistDetailUseCase: DIContainer.shared.resolve(GetPlaylistDetailUseCaseProtocol.self)!,
            updatePlaylistUseCase: DIContainer.shared.resolve(UpdatePlaylistUseCaseProtocol.self)!,
            removeTracksFromPlaylistUseCase: DIContainer.shared.resolve(RemoveTracksFromPlaylistUseCaseProtocol.self)!
        )
        let playlistVC = playlistCoordinator.start()
        playlistVC.navigationItem.largeTitleDisplayMode = .inline
        playlistNav.setViewControllers([playlistVC], animated: false)
        childCoordinators.append(playlistCoordinator)
        
        let settingsNav = UINavigationController()
        settingsNav.navigationBar.isHidden = true
        let settingsCoordinator = SettingsCoordinator(navigationController: settingsNav)
        settingsCoordinator.delegate = self
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

extension MainTabBarCoordinator: SettingsCoordinatorDelegate {
    public func settingsCoordinatorDidFinish(_ coordinator: SettingsCoordinator) {
        removeChild(coordinator)
    }
    
    public func settingsCoordinatorDidLogout(_ coordinator: SettingsCoordinator) {
        delegate?.mainTabBarCoordinatorDidLogout(self)
    }
}
