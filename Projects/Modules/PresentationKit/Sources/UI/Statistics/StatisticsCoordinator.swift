import UIKit
import DIKit
import DomainKit
import FoundationKit

public protocol StatisticsCoordinatorDelegate: AnyObject {
    func statisticsCoordinatorDidFinish(_ coordinator: StatisticsCoordinator)
}

public final class StatisticsCoordinator {
    public var childCoordinators: [AnyObject] = []
    public let navigationController: UINavigationController
    public weak var delegate: StatisticsCoordinatorDelegate?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() -> UIViewController {
        guard let reactor = resolve(StatisticsReactor.self) else {
            fatalError("error.di.statisticsReactorResolution".localized())
        }
        let statisticsVC = StatisticsViewController(reactor: reactor)
        statisticsVC.coordinator = self
        return statisticsVC
    }
    
    public func removeChild(_ child: AnyObject) {
        childCoordinators.removeAll { $0 === child }
    }

    // MARK: - Navigation
    public func showArtistDetail(_ artist: SpotifyArtist) {
        let coordinator = ArtistDetailCoordinator(navigationController: navigationController)
        childCoordinators.append(coordinator)
        let vc = coordinator.start(with: artist)
        navigationController.pushViewController(vc, animated: true)
    }

    public func showTrackDetail(_ track: SpotifyTrack) {
        let coordinator = TrackDetailCoordinator(navigationController: navigationController)
        childCoordinators.append(coordinator)
        let vc = coordinator.start(with: track)
        navigationController.pushViewController(vc, animated: true)
    }
}
