import UIKit
import DomainKit
import DIKit

public protocol PlaylistDetailCoordinatorDelegate: AnyObject {
    func playlistDetailCoordinatorDidFinish(_ coordinator: PlaylistDetailCoordinator)
}

public final class PlaylistDetailCoordinator {
    public var childCoordinators: [AnyObject] = []
    public let navigationController: UINavigationController
    public weak var delegate: PlaylistDetailCoordinatorDelegate?

    private let playlist: Playlist
    private let getPlaylistDetailUseCase: GetPlaylistDetailUseCaseProtocol
    private let updatePlaylistUseCase: UpdatePlaylistUseCaseProtocol
    private let removeTracksFromPlaylistUseCase: RemoveTracksFromPlaylistUseCaseProtocol

    public init(
        navigationController: UINavigationController,
        playlist: Playlist,
        getPlaylistDetailUseCase: GetPlaylistDetailUseCaseProtocol,
        updatePlaylistUseCase: UpdatePlaylistUseCaseProtocol,
        removeTracksFromPlaylistUseCase: RemoveTracksFromPlaylistUseCaseProtocol
    ) {
        self.navigationController = navigationController
        self.playlist = playlist
        self.getPlaylistDetailUseCase = getPlaylistDetailUseCase
        self.updatePlaylistUseCase = updatePlaylistUseCase
        self.removeTracksFromPlaylistUseCase = removeTracksFromPlaylistUseCase
    }

    public func start() -> UIViewController {
        let playbackControlUseCase = DIContainer.shared.resolve(PlaybackControlUseCaseProtocol.self)!
        let reactor = PlaylistDetailReactor(
            playlist: playlist,
            getPlaylistDetailUseCase: getPlaylistDetailUseCase,
            updatePlaylistUseCase: updatePlaylistUseCase,
            removeTracksFromPlaylistUseCase: removeTracksFromPlaylistUseCase,
            playbackControlUseCase: playbackControlUseCase
        )
        reactor.coordinator = self

        let playlistDetailVC = PlaylistDetailViewController(reactor: reactor)
        playlistDetailVC.coordinator = self

        return playlistDetailVC
    }

    public func showTrackDetail(track: PlaylistTrack) {
        // PlaylistTrack의 제한된 정보로 SpotifyArtist와 SpotifyAlbum 객체 생성
        let spotifyArtists = track.artists.enumerated().map { index, artistName in
            SpotifyArtist(
                id: "unknown_artist_\(index)",
                name: artistName,
                uri: "spotify:artist:unknown_\(index)"
            )
        }

        // 앨범 이미지 처리
        let albumImages: [SpotifyImage] = track.albumImageUrl.map { imageUrl in
            [SpotifyImage(url: imageUrl, height: 640, width: 640)]
        } ?? []

        let spotifyAlbum = SpotifyAlbum(
            id: "unknown_album",
            name: track.album,
            images: albumImages,
            releaseDate: "",
            totalTracks: 1,
            artists: spotifyArtists,
            uri: "spotify:album:unknown"
        )

        // SpotifyTrack 생성
        let spotifyTrack = SpotifyTrack(
            id: track.id,
            name: track.name,
            artists: spotifyArtists,
            album: spotifyAlbum,
            durationMs: track.durationMs,
            popularity: track.popularity ?? 0,
            previewUrl: track.previewUrl,
            uri: track.uri
        )

        let coordinator = TrackDetailCoordinator(navigationController: navigationController)
        coordinator.delegate = self
        childCoordinators.append(coordinator)
        let vc = coordinator.start(with: spotifyTrack)
        navigationController.pushViewController(vc, animated: true)
    }

    public func showTrackSearch(playlist: Playlist) {
        let searchTracksUseCase = DIContainer.shared.resolve(SearchTracksUseCaseProtocol.self)!
        let addTracksToPlaylistUseCase = DIContainer.shared.resolve(AddTracksToPlaylistUseCaseProtocol.self)!

        let trackSearchCoordinator = TrackSearchCoordinator(
            navigationController: navigationController,
            playlist: playlist,
            searchTracksUseCase: searchTracksUseCase,
            addTracksToPlaylistUseCase: addTracksToPlaylistUseCase
        )

        trackSearchCoordinator.delegate = self
        let trackSearchVC = trackSearchCoordinator.start()

        childCoordinators.append(trackSearchCoordinator)
        navigationController.pushViewController(trackSearchVC, animated: true)
    }

    public func removeChild(_ child: AnyObject) {
        childCoordinators.removeAll { $0 === child }
    }
}

// MARK: - TrackSearchCoordinatorDelegate

extension PlaylistDetailCoordinator: TrackSearchCoordinatorDelegate {
    public func trackSearchCoordinatorDidFinish(_ coordinator: TrackSearchCoordinator) {
        removeChild(coordinator)
        navigationController.popViewController(animated: true)
    }

    public func trackSearchCoordinator(_ coordinator: TrackSearchCoordinator, didAddTracksToPlaylist playlist: Playlist) {
        // This can be used for future implementations if needed
        print("Tracks added to playlist: \(playlist.name)")
    }
}

// MARK: - TrackDetailCoordinatorDelegate

extension PlaylistDetailCoordinator: TrackDetailCoordinatorDelegate {
    public func trackDetailCoordinatorDidFinish(_ coordinator: TrackDetailCoordinator) {
        removeChild(coordinator)
    }
}
