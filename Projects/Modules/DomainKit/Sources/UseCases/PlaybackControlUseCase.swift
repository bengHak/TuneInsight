import Foundation

public protocol PlaybackControlUseCaseProtocol {
    func play() async throws
    func pause() async throws
    func nextTrack() async throws
    func previousTrack() async throws
    func seek(to positionMs: Int) async throws
}

public final class PlaybackControlUseCase: PlaybackControlUseCaseProtocol, Sendable {
    private let repository: SpotifyRepository
    
    public init(repository: SpotifyRepository) {
        self.repository = repository
    }
    
    public func play() async throws {
        try await repository.play()
    }
    
    public func pause() async throws {
        try await repository.pause()
    }
    
    public func nextTrack() async throws {
        try await repository.nextTrack()
    }
    
    public func previousTrack() async throws {
        try await repository.previousTrack()
    }
    
    public func seek(to positionMs: Int) async throws {
        try await repository.seek(to: positionMs)
    }
}