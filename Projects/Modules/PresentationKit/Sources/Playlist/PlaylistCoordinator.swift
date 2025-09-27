import UIKit
import DomainKit

public protocol PlaylistCoordinatorDelegate: AnyObject {
    func playlistCoordinatorDidFinish(_ coordinator: PlaylistCoordinator)
}

public final class PlaylistCoordinator {
    public var childCoordinators: [AnyObject] = []
    public let navigationController: UINavigationController
    public weak var delegate: PlaylistCoordinatorDelegate?

    // Dependencies - these will be injected from DI container
    private let getUserPlaylistsUseCase: GetUserPlaylistsUseCaseProtocol
    private let createPlaylistUseCase: CreatePlaylistUseCaseProtocol
    private let deletePlaylistUseCase: DeletePlaylistUseCaseProtocol
    private let getPlaylistDetailUseCase: GetPlaylistDetailUseCaseProtocol
    private let updatePlaylistUseCase: UpdatePlaylistUseCaseProtocol
    private let removeTracksFromPlaylistUseCase: RemoveTracksFromPlaylistUseCaseProtocol

    public init(
        navigationController: UINavigationController,
        getUserPlaylistsUseCase: GetUserPlaylistsUseCaseProtocol,
        createPlaylistUseCase: CreatePlaylistUseCaseProtocol,
        deletePlaylistUseCase: DeletePlaylistUseCaseProtocol,
        getPlaylistDetailUseCase: GetPlaylistDetailUseCaseProtocol,
        updatePlaylistUseCase: UpdatePlaylistUseCaseProtocol,
        removeTracksFromPlaylistUseCase: RemoveTracksFromPlaylistUseCaseProtocol
    ) {
        self.navigationController = navigationController
        self.getUserPlaylistsUseCase = getUserPlaylistsUseCase
        self.createPlaylistUseCase = createPlaylistUseCase
        self.deletePlaylistUseCase = deletePlaylistUseCase
        self.getPlaylistDetailUseCase = getPlaylistDetailUseCase
        self.updatePlaylistUseCase = updatePlaylistUseCase
        self.removeTracksFromPlaylistUseCase = removeTracksFromPlaylistUseCase
    }

    public func start() -> UIViewController {
        let reactor = PlaylistListReactor(
            getUserPlaylistsUseCase: getUserPlaylistsUseCase,
            createPlaylistUseCase: createPlaylistUseCase,
            deletePlaylistUseCase: deletePlaylistUseCase
        )
        reactor.coordinator = self

        let playlistVC = PlaylistViewController(reactor: reactor)
        playlistVC.coordinator = self

        return playlistVC
    }

    public func showPlaylistDetail(playlist: Playlist) {
        let playlistDetailCoordinator = PlaylistDetailCoordinator(
            navigationController: navigationController,
            playlist: playlist,
            getPlaylistDetailUseCase: getPlaylistDetailUseCase,
            updatePlaylistUseCase: updatePlaylistUseCase,
            removeTracksFromPlaylistUseCase: removeTracksFromPlaylistUseCase
        )

        let playlistDetailVC = playlistDetailCoordinator.start()
        childCoordinators.append(playlistDetailCoordinator)

        navigationController.pushViewController(playlistDetailVC, animated: true)
    }

    public func showCreatePlaylist() {
        let createPlaylistCoordinator = CreatePlaylistCoordinatorImpl(
            navigationController: navigationController,
            createPlaylistUseCase: createPlaylistUseCase
        )

        childCoordinators.append(createPlaylistCoordinator)
        createPlaylistCoordinator.start()
    }

    public func showTrackSearch(for playlist: Playlist) {
        // TODO: Implement track search navigation
        print("Navigate to track search for playlist: \(playlist.name)")
    }

    public func removeChild(_ child: AnyObject) {
        childCoordinators.removeAll { $0 === child }
    }
}
