import Foundation

public protocol GetTopArtistsUseCaseProtocol {
    func execute(
        timeRange: TopArtistTimeRange,
        limit: Int,
        offset: Int
    ) async throws -> [TopArtist]
}

public final class GetTopArtistsUseCase: GetTopArtistsUseCaseProtocol, Sendable {
    private let repository: SpotifyRepository

    public init(repository: SpotifyRepository) {
        self.repository = repository
    }

    public func execute(
        timeRange: TopArtistTimeRange = .mediumTerm,
        limit: Int = 10,
        offset: Int = 0
    ) async throws -> [TopArtist] {
        return try await repository.getTopArtists(
            timeRange: timeRange,
            limit: limit,
            offset: offset
        )
    }
}