import Foundation
import DIKit
import DomainKit
import Swinject

public final class PresentationAssembly: DIAssembly {
    
    public init() {}
    
    public func assemble(container: Container) {
        assembleReactors(container: container)
    }
    
    private func assembleReactors(container: Container) {
        container.register(HomeReactor.self) { resolver in
            let getCurrentPlaybackUseCase = resolver.resolve(GetCurrentPlaybackUseCaseProtocol.self)!
            let getRecentlyPlayedUseCase = resolver.resolve(GetRecentlyPlayedUseCaseProtocol.self)!
            let playbackControlUseCase = resolver.resolve(PlaybackControlUseCaseProtocol.self)!
            
            return HomeReactor(
                getCurrentPlaybackUseCase: getCurrentPlaybackUseCase,
                getRecentlyPlayedUseCase: getRecentlyPlayedUseCase,
                playbackControlUseCase: playbackControlUseCase
            )
        }
    }
}