import Foundation
import DIKit
import DomainKit
import Swinject

public final class MockAssembly: DIAssembly {
    
    public init() {}
    
    public func assemble(container: Container) {
        assembleMockRepositories(container: container)
        assembleMockUseCases(container: container)
        assembleReactors(container: container)
    }
    
    private func assembleMockRepositories(container: Container) {
        container.register(SpotifyRepository.self) { _ in
            MockSpotifyRepository()
        }
        .inObjectScope(.container)
    }
    
    private func assembleMockUseCases(container: Container) {
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
    
    private func assembleSpotifyStateManager(container: Container) {
        container.register(SpotifyStateManager.self) { resolver in
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
        .inObjectScope(.container)
    }
    
    private func assembleReactors(container: Container) {
        container.register(HomeReactor.self) { resolver in
            let spotifyStateManager = resolver.resolve(SpotifyStateManager.self)!
            return HomeReactor(spotifyStateManager: spotifyStateManager)
        }
    }
}

private class MockSpotifyRepository: SpotifyRepository {
    func getCurrentPlayback() async throws -> CurrentPlayback {
        let mockTrack = SpotifyTrack(
            id: "mock-id",
            name: "Mock Song",
            artists: [SpotifyArtist(id: "artist-id", name: "Mock Artist", uri: "spotify:artist:mock", images: [], genres: [], popularity: nil)],
            album: SpotifyAlbum(id: "album-id", name: "Mock Album", images: [], releaseDate: "2023-01-01", totalTracks: 10, artists: [], uri: "spotify:album:mock"),
            durationMs: 210000,
            popularity: 85,
            previewUrl: nil,
            uri: "spotify:track:mock"
        )
        
        return CurrentPlayback(
            track: mockTrack,
            isPlaying: true,
            progressMs: 60000,
            device: nil,
            shuffleState: false,
            repeatState: .off,
            timestamp: Int64(Date().timeIntervalSince1970 * 1000)
        )
    }
    
    func getRecentlyPlayed(limit: Int) async throws -> [RecentTrack] {
        let mockTrack = SpotifyTrack(
            id: "recent-id",
            name: "Recent Song",
            artists: [SpotifyArtist(id: "artist-id", name: "Recent Artist", uri: "spotify:artist:recent", images: [], genres: [], popularity: nil)],
            album: SpotifyAlbum(id: "album-id", name: "Recent Album", images: [], releaseDate: "2023-01-01", totalTracks: 10, artists: [], uri: "spotify:album:recent"),
            durationMs: 180000,
            popularity: 75,
            previewUrl: nil,
            uri: "spotify:track:recent"
        )
        
        return Array(repeating: RecentTrack(track: mockTrack, playedAt: Date(), context: nil), count: min(limit, 5))
    }
    
    func play() async throws {}
    func pause() async throws {}
    func nextTrack() async throws {}
    func previousTrack() async throws {}
    func seek(to positionMs: Int) async throws {}
}
