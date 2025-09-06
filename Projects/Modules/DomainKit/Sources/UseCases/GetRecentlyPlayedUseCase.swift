import Foundation

public protocol GetRecentlyPlayedUseCaseProtocol {
    func execute(limit: Int) async throws -> [RecentTrack]
}

public final class GetRecentlyPlayedUseCase: GetRecentlyPlayedUseCaseProtocol, Sendable {
    private let repository: SpotifyRepository
    
    public init(repository: SpotifyRepository) {
        self.repository = repository
    }
    
    public func execute(limit: Int = 5) async throws -> [RecentTrack] {
        return try await repository.getRecentlyPlayed(limit: limit)
    }
}