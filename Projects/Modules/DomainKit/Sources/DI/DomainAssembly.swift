import Foundation
import DIKit
import Swinject

public final class DomainAssembly: DIAssembly {
    
    public init() {}
    
    public func assemble(container: Container) {
        assembleUseCases(container: container)
    }
    
    private func assembleUseCases(container: Container) {
        container.register(GetCurrentPlaybackUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(SpotifyRepository.self)!
            return GetCurrentPlaybackUseCase(repository: repository)
        }
        
        container.register(GetRecentlyPlayedUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(SpotifyRepository.self)!
            return GetRecentlyPlayedUseCase(repository: repository)
        }
        
        container.register(PlaybackControlUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(SpotifyRepository.self)!
            return PlaybackControlUseCase(repository: repository)
        }
        
        container.register(GetTopArtistsUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(SpotifyRepository.self)!
            return GetTopArtistsUseCase(repository: repository)
        }
        
        container.register(GetTopTracksUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(SpotifyRepository.self)!
            return GetTopTracksUseCase(repository: repository)
        }

        // Artist Detail Related UseCases
        container.register(GetArtistUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(SpotifyRepository.self)!
            return GetArtistUseCase(repository: repository)
        }

        container.register(GetArtistsUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(SpotifyRepository.self)!
            return GetArtistsUseCase(repository: repository)
        }

        container.register(GetArtistAlbumsUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(SpotifyRepository.self)!
            return GetArtistAlbumsUseCase(repository: repository)
        }

        container.register(GetArtistTopTracksUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(SpotifyRepository.self)!
            return GetArtistTopTracksUseCase(repository: repository)
        }

        container.register(GetAlbumTracksUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(SpotifyRepository.self)!
            return GetAlbumTracksUseCase(repository: repository)
        }

        // Playlist Related UseCases
        container.register(GetUserPlaylistsUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(SpotifyRepository.self)!
            return GetUserPlaylistsUseCase(repository: repository)
        }

        container.register(GetPlaylistDetailUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(SpotifyRepository.self)!
            return GetPlaylistDetailUseCase(repository: repository)
        }

        container.register(CreatePlaylistUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(SpotifyRepository.self)!
            return CreatePlaylistUseCase(repository: repository)
        }

        container.register(UpdatePlaylistUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(SpotifyRepository.self)!
            return UpdatePlaylistUseCase(repository: repository)
        }

        container.register(DeletePlaylistUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(SpotifyRepository.self)!
            return DeletePlaylistUseCase(repository: repository)
        }

        container.register(AddTracksToPlaylistUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(SpotifyRepository.self)!
            return AddTracksToPlaylistUseCase(repository: repository)
        }

        container.register(RemoveTracksFromPlaylistUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(SpotifyRepository.self)!
            return RemoveTracksFromPlaylistUseCase(repository: repository)
        }

        container.register(SearchTracksUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(SpotifyRepository.self)!
            return SearchTracksUseCase(repository: repository)
        }
    }
}
