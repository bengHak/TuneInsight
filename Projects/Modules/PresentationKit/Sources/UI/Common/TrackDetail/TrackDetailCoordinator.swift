import UIKit
import DomainKit
import DIKit
import FoundationKit

public protocol TrackDetailCoordinatorDelegate: AnyObject {
    func trackDetailCoordinatorDidFinish(_ coordinator: TrackDetailCoordinator)
}

public final class TrackDetailCoordinator {
    public var childCoordinators: [AnyObject] = []
    public let navigationController: UINavigationController
    public weak var delegate: TrackDetailCoordinatorDelegate?

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    public func start(with track: SpotifyTrack) -> UIViewController {
        // Reactor는 DI에서 의존성 주입 후 직접 생성
        guard let playbackControl = resolve(PlaybackControlUseCaseProtocol.self),
              let stateManager = resolve(SpotifyStateManagerProtocol.self) else {
            fatalError("error.di.trackDetailResolution".localized())
        }

        let reactor = TrackDetailReactor(
            track: track,
            playbackControlUseCase: playbackControl,
            spotifyStateManager: stateManager
        )
        let viewController = TrackDetailViewController(reactor: reactor)
        viewController.coordinator = self
        return viewController
    }

    public func removeChild(_ child: AnyObject) {
        childCoordinators.removeAll { $0 === child }
    }

    public func showAlbumDetail(album: SpotifyAlbum) {
        let coordinator = AlbumDetailCoordinator(navigationController: navigationController)
        coordinator.delegate = self
        childCoordinators.append(coordinator)
        let viewController = coordinator.start(with: album)
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension TrackDetailCoordinator: AlbumDetailCoordinatorDelegate {
    public func albumDetailCoordinatorDidFinish(_ coordinator: AlbumDetailCoordinator) {
        removeChild(coordinator)
    }
}
