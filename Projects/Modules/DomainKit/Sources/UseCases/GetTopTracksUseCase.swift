import Foundation

public protocol GetTopTracksUseCaseProtocol {
    func execute(
        timeRange: SpotifyTimeRange,
        limit: Int,
        offset: Int
    ) async throws -> [TopTrack]
}

public final class GetTopTracksUseCase: GetTopTracksUseCaseProtocol, Sendable {
    private let repository: SpotifyRepository

    public init(repository: SpotifyRepository) {
        self.repository = repository
    }

    public func execute(
        timeRange: SpotifyTimeRange = .mediumTerm,
        limit: Int = 20,
        offset: Int = 0
    ) async throws -> [TopTrack] {
        return try await repository.getTopTracks(
            timeRange: timeRange,
            limit: limit,
            offset: offset
        )
    }
}

