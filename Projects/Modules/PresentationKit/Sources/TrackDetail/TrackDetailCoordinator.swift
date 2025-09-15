import UIKit
import DomainKit
import DIKit

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
            fatalError("TrackDetailReactor 의존성을 resolve할 수 없습니다. DI 설정을 확인해주세요.")
        }

        let reactor = TrackDetailReactor(
            track: track,
            playbackControlUseCase: playbackControl,
            spotifyStateManager: stateManager
        )
        let viewController = TrackDetailViewController(reactor: reactor)
        return viewController
    }

    public func removeChild(_ child: AnyObject) {
        childCoordinators.removeAll { $0 === child }
    }
}

