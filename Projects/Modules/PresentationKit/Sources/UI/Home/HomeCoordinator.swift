import UIKit
import DomainKit
import DIKit
import FoundationKit
// ArtistDetailCoordinator, TrackDetailCoordinator 등 화면 이동

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
        // DIContainer에서 HomeReactor resolve
        guard let homeReactor = resolve(HomeReactor.self) else {
            fatalError("error.di.homeReactorResolution".localized())
        }
        
        // ViewController 생성
        let homeVC = HomeViewController(reactor: homeReactor)
        homeVC.title = "app.name".localized()
        homeVC.coordinator = self
        return homeVC
    }
    
    public func removeChild(_ child: AnyObject) {
        childCoordinators.removeAll { $0 === child }
    }

    // MARK: - Navigation
    public func showTrackDetail(_ track: SpotifyTrack) {
        let coordinator = TrackDetailCoordinator(navigationController: navigationController)
        childCoordinators.append(coordinator)
        let vc = coordinator.start(with: track)
        navigationController.pushViewController(vc, animated: true)
    }

    public func showArtistDetail(_ artist: SpotifyArtist) {
        let coordinator = ArtistDetailCoordinator(navigationController: navigationController)
        childCoordinators.append(coordinator)
        let vc = coordinator.start(with: artist)
        navigationController.pushViewController(vc, animated: true)
    }
}
