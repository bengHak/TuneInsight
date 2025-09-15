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
        return vc
    }

    public func removeChild(_ child: AnyObject) {
        childCoordinators.removeAll { $0 === child }
    }
}

