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
    }
}