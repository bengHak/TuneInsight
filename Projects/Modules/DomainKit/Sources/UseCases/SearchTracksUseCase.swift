import Foundation

public protocol SearchTracksUseCaseProtocol {
    func execute(query: String, limit: Int?, offset: Int?, market: String?) async throws -> SearchTracksPage
}

public final class SearchTracksUseCase: SearchTracksUseCaseProtocol, Sendable {
    private let repository: SpotifyRepository

    public init(repository: SpotifyRepository) {
        self.repository = repository
    }

    public func execute(query: String, limit: Int? = 20, offset: Int? = 0, market: String? = nil) async throws -> SearchTracksPage {
        return try await repository.searchTracks(
            query: query,
            limit: limit,
            offset: offset,
            market: market
        )
    }
}