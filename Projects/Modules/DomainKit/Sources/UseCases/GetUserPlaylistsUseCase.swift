import Foundation

public protocol GetUserPlaylistsUseCaseProtocol {
    func execute(limit: Int?, offset: Int?) async throws -> PlaylistsPage
}

public final class GetUserPlaylistsUseCase: GetUserPlaylistsUseCaseProtocol, Sendable {
    private let repository: SpotifyRepository

    public init(repository: SpotifyRepository) {
        self.repository = repository
    }

    public func execute(limit: Int? = 20, offset: Int? = 0) async throws -> PlaylistsPage {
        return try await repository.getUserPlaylists(limit: limit, offset: offset)
    }
}