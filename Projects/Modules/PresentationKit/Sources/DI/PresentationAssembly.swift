import Foundation
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
            SpotifyStateManager.shared.configure(
                getCurrentPlaybackUseCase: getCurrentPlaybackUseCase,
                getRecentlyPlayedUseCase: getRecentlyPlayedUseCase,
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
    }
}
