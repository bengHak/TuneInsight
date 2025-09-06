import Foundation

public protocol GetCurrentPlaybackUseCaseProtocol {
    func execute() async throws -> CurrentPlayback
}

public final class GetCurrentPlaybackUseCase: GetCurrentPlaybackUseCaseProtocol, Sendable {
    private let repository: SpotifyRepository
    
    public init(repository: SpotifyRepository) {
        self.repository = repository
    }
    
    public func execute() async throws -> CurrentPlayback {
        return try await repository.getCurrentPlayback()
    }
}