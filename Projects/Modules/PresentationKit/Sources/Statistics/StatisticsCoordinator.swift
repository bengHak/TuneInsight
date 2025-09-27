import UIKit
import DIKit
import DomainKit

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
            fatalError("StatisticsReactor를 resolve할 수 없습니다. DI 설정을 확인해주세요.")
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
}
