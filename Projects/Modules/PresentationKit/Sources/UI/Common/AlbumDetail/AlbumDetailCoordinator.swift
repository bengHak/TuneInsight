import UIKit
import DomainKit
import DIKit

public protocol AlbumDetailCoordinatorDelegate: AnyObject {
    func albumDetailCoordinatorDidFinish(_ coordinator: AlbumDetailCoordinator)
}

public final class AlbumDetailCoordinator {
    public var childCoordinators: [AnyObject] = []
    public let navigationController: UINavigationController
    public weak var delegate: AlbumDetailCoordinatorDelegate?

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    public func start(with album: SpotifyAlbum) -> UIViewController {
        guard let albumTracksUseCase = resolve(GetAlbumTracksUseCaseProtocol.self) else {
            fatalError("AlbumDetail 의존성을 resolve할 수 없습니다. DI 설정을 확인해주세요.")
        }

        let reactor = AlbumDetailReactor(
            album: album,
            getAlbumTracksUseCase: albumTracksUseCase
        )
        let viewController = AlbumDetailViewController(reactor: reactor)
        viewController.coordinator = self
        return viewController
    }

    public func removeChild(_ child: AnyObject) {
        childCoordinators.removeAll { $0 === child }
    }

    public func showTrackDetail(track: SpotifyTrack) {
        let coordinator = TrackDetailCoordinator(navigationController: navigationController)
        coordinator.delegate = self
        childCoordinators.append(coordinator)
        let viewController = coordinator.start(with: track)
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension AlbumDetailCoordinator: TrackDetailCoordinatorDelegate {
    public func trackDetailCoordinatorDidFinish(_ coordinator: TrackDetailCoordinator) {
        removeChild(coordinator)
    }
}
