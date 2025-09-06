import UIKit
import DomainKit
import DataKit

public protocol HomeCoordinatorDelegate: AnyObject {
    func homeCoordinatorDidFinish(_ coordinator: HomeCoordinator)
}

public final class HomeCoordinator {
    public var childCoordinators: [AnyObject] = []
    public let navigationController: UINavigationController
    public weak var delegate: HomeCoordinatorDelegate?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() -> UIViewController {
        // Repository 생성
        let spotifyRepository = SpotifyRepositoryImpl()
        
        // Use Cases 생성
        let getCurrentPlaybackUseCase = GetCurrentPlaybackUseCase(repository: spotifyRepository)
        let getRecentlyPlayedUseCase = GetRecentlyPlayedUseCase(repository: spotifyRepository)
        let playbackControlUseCase = PlaybackControlUseCase(repository: spotifyRepository)
        
        // Reactor 생성 (의존성 주입)
        let homeReactor = HomeReactor(
            getCurrentPlaybackUseCase: getCurrentPlaybackUseCase,
            getRecentlyPlayedUseCase: getRecentlyPlayedUseCase,
            playbackControlUseCase: playbackControlUseCase
        )
        
        // ViewController 생성
        let homeVC = HomeViewController(reactor: homeReactor)
        homeVC.coordinator = self
        return homeVC
    }
    
    public func removeChild(_ child: AnyObject) {
        childCoordinators.removeAll { $0 === child }
    }
}