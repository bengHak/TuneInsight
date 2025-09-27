import UIKit
import DomainKit

public protocol TrackSearchCoordinatorDelegate: AnyObject {
    func trackSearchCoordinatorDidFinish(_ coordinator: TrackSearchCoordinator)
    func trackSearchCoordinator(_ coordinator: TrackSearchCoordinator, didAddTracksToPlaylist playlist: Playlist)
}

public final class TrackSearchCoordinator {
    public var childCoordinators: [AnyObject] = []
    public let navigationController: UINavigationController
    public weak var delegate: TrackSearchCoordinatorDelegate?

    private let playlist: Playlist
    private let searchTracksUseCase: SearchTracksUseCaseProtocol
    private let addTracksToPlaylistUseCase: AddTracksToPlaylistUseCaseProtocol

    public init(
        navigationController: UINavigationController,
        playlist: Playlist,
        searchTracksUseCase: SearchTracksUseCaseProtocol,
        addTracksToPlaylistUseCase: AddTracksToPlaylistUseCaseProtocol
    ) {
        self.navigationController = navigationController
        self.playlist = playlist
        self.searchTracksUseCase = searchTracksUseCase
        self.addTracksToPlaylistUseCase = addTracksToPlaylistUseCase
    }

    public func start() -> UIViewController {
        let reactor = TrackSearchReactor(
            playlist: playlist,
            searchTracksUseCase: searchTracksUseCase,
            addTracksToPlaylistUseCase: addTracksToPlaylistUseCase
        )
        reactor.coordinator = self

        let trackSearchVC = TrackSearchViewController(reactor: reactor, playlist: playlist)
        trackSearchVC.coordinator = self

        return trackSearchVC
    }

    public func finishTrackSearch() {
        delegate?.trackSearchCoordinatorDidFinish(self)
    }

    public func removeChild(_ child: AnyObject) {
        childCoordinators.removeAll { $0 === child }
    }
}