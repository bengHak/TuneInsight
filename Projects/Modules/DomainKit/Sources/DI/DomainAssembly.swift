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
    }
}
