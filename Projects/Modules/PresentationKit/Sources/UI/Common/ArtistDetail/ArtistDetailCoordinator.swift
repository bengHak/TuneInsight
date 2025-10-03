import UIKit
import DomainKit
import DIKit

public protocol ArtistDetailCoordinatorDelegate: AnyObject {
    func artistDetailCoordinatorDidFinish(_ coordinator: ArtistDetailCoordinator)
}

public final class ArtistDetailCoordinator {
    public var childCoordinators: [AnyObject] = []
    public let navigationController: UINavigationController
    public weak var delegate: ArtistDetailCoordinatorDelegate?

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    public func start(with artist: SpotifyArtist) -> UIViewController {
        // Reactor 생성: DI에서 유스케이스 resolve 후 수동 주입
        guard let albumsUseCase = resolve(GetArtistAlbumsUseCaseProtocol.self),
              let topTracksUseCase = resolve(GetArtistTopTracksUseCaseProtocol.self) else {
            fatalError("ArtistDetail 의존성을 resolve할 수 없습니다. DI 설정을 확인해주세요.")
        }
        let reactor = ArtistDetailReactor(
            artist: artist,
            getArtistAlbumsUseCase: albumsUseCase,
            getArtistTopTracksUseCase: topTracksUseCase
        )
        let vc = ArtistDetailViewController(reactor: reactor)
        vc.coordinator = self
        return vc
    }

    public func removeChild(_ child: AnyObject) {
        childCoordinators.removeAll { $0 === child }
    }

    public func showAlbumDetail(album: SpotifyAlbum) {
        let coordinator = AlbumDetailCoordinator(navigationController: navigationController)
        coordinator.delegate = self
        childCoordinators.append(coordinator)
        let vc = coordinator.start(with: album)
        navigationController.pushViewController(vc, animated: true)
    }

    public func showTrackDetail(track: SpotifyTrack) {
        let coordinator = TrackDetailCoordinator(navigationController: navigationController)
        coordinator.delegate = self
        childCoordinators.append(coordinator)
        let viewController = coordinator.start(with: track)
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension ArtistDetailCoordinator: AlbumDetailCoordinatorDelegate {
    public func albumDetailCoordinatorDidFinish(_ coordinator: AlbumDetailCoordinator) {
        removeChild(coordinator)
    }
}

extension ArtistDetailCoordinator: TrackDetailCoordinatorDelegate {
    public func trackDetailCoordinatorDidFinish(_ coordinator: TrackDetailCoordinator) {
        removeChild(coordinator)
    }
}
