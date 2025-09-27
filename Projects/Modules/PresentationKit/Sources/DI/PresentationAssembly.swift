import Foundation
import UIKit
import DIKit
import DomainKit
import Swinject

public final class PresentationAssembly: DIAssembly {
    
    public init() {}
    
    public func assemble(container: Container) {
        assembleSpotifyStateManager(container: container)
        assembleReactors(container: container)
    }
    
    private func assembleSpotifyStateManager(container: Container) {
        container.register(SpotifyStateManagerProtocol.self) { resolver in
            let getCurrentPlaybackUseCase = resolver.resolve(GetCurrentPlaybackUseCaseProtocol.self)!
            let getRecentlyPlayedUseCase = resolver.resolve(GetRecentlyPlayedUseCaseProtocol.self)!
            let playbackControlUseCase = resolver.resolve(PlaybackControlUseCaseProtocol.self)!
            let getTopArtistsUseCase = resolver.resolve(GetTopArtistsUseCaseProtocol.self)!
            let getTopTracksUseCase = resolver.resolve(GetTopTracksUseCaseProtocol.self)!
            SpotifyStateManager.shared.configure(
                getCurrentPlaybackUseCase: getCurrentPlaybackUseCase,
                getRecentlyPlayedUseCase: getRecentlyPlayedUseCase,
                getTopArtistsUseCase: getTopArtistsUseCase,
                getTopTracksUseCase: getTopTracksUseCase,
                playbackControlUseCase: playbackControlUseCase
            )
            return SpotifyStateManager.shared
        }
    }
    
    private func assembleReactors(container: Container) {
        container.register(HomeReactor.self) { resolver in
            let spotifyStateManager = resolver.resolve(SpotifyStateManagerProtocol.self)!
            return HomeReactor(spotifyStateManager: spotifyStateManager)
        }

        container.register(StatisticsReactor.self) { resolver in
            let stateManager = resolver.resolve(SpotifyStateManagerProtocol.self)!
            return StatisticsReactor(spotifyStateManager: stateManager)
        }

        // Playlist Coordinator factory registration
        container.register(PlaylistCoordinator.self) { (resolver: Resolver, navigationController: UINavigationController) in
            let getUserPlaylistsUseCase = resolver.resolve(GetUserPlaylistsUseCaseProtocol.self)!
            let createPlaylistUseCase = resolver.resolve(CreatePlaylistUseCaseProtocol.self)!
            let deletePlaylistUseCase = resolver.resolve(DeletePlaylistUseCaseProtocol.self)!
            let getPlaylistDetailUseCase = resolver.resolve(GetPlaylistDetailUseCaseProtocol.self)!
            let updatePlaylistUseCase = resolver.resolve(UpdatePlaylistUseCaseProtocol.self)!
            let removeTracksFromPlaylistUseCase = resolver.resolve(RemoveTracksFromPlaylistUseCaseProtocol.self)!

            return PlaylistCoordinator(
                navigationController: navigationController,
                getUserPlaylistsUseCase: getUserPlaylistsUseCase,
                createPlaylistUseCase: createPlaylistUseCase,
                deletePlaylistUseCase: deletePlaylistUseCase,
                getPlaylistDetailUseCase: getPlaylistDetailUseCase,
                updatePlaylistUseCase: updatePlaylistUseCase,
                removeTracksFromPlaylistUseCase: removeTracksFromPlaylistUseCase
            )
        }

        // TrackDetailReactor factory registration
        container.register(TrackDetailReactor.self) { (resolver: Resolver, track: SpotifyTrack) in
            let playbackControl = resolver.resolve(PlaybackControlUseCaseProtocol.self)!
            let stateManager = resolver.resolve(SpotifyStateManagerProtocol.self)!
            return TrackDetailReactor(
                track: track,
                playbackControlUseCase: playbackControl,
                spotifyStateManager: stateManager
            )
        }

        // ArtistDetailReactor factory registration
        container.register(ArtistDetailReactor.self) { (resolver: Resolver, artist: SpotifyArtist) in
            let albums = resolver.resolve(GetArtistAlbumsUseCaseProtocol.self)!
            let topTracks = resolver.resolve(GetArtistTopTracksUseCaseProtocol.self)!
            return ArtistDetailReactor(
                artist: artist,
                getArtistAlbumsUseCase: albums,
                getArtistTopTracksUseCase: topTracks
            )
        }

        // AlbumDetailReactor factory registration
        container.register(AlbumDetailReactor.self) { (resolver: Resolver, album: SpotifyAlbum) in
            let albumTracks = resolver.resolve(GetAlbumTracksUseCaseProtocol.self)!
            return AlbumDetailReactor(
                album: album,
                getAlbumTracksUseCase: albumTracks
            )
        }

        // TrackSearchCoordinator factory registration
        container.register(TrackSearchCoordinator.self) { (resolver: Resolver, navigationController: UINavigationController, playlist: Playlist) in
            let searchTracksUseCase = resolver.resolve(SearchTracksUseCaseProtocol.self)!
            let addTracksToPlaylistUseCase = resolver.resolve(AddTracksToPlaylistUseCaseProtocol.self)!

            return TrackSearchCoordinator(
                navigationController: navigationController,
                playlist: playlist,
                searchTracksUseCase: searchTracksUseCase,
                addTracksToPlaylistUseCase: addTracksToPlaylistUseCase
            )
        }
    }
}
