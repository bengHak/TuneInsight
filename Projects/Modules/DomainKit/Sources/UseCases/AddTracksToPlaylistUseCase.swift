import Foundation

public protocol AddTracksToPlaylistUseCaseProtocol {
    func execute(playlistId: String, trackUris: [String], position: Int?) async throws -> String
}

public final class AddTracksToPlaylistUseCase: AddTracksToPlaylistUseCaseProtocol, Sendable {
    private let repository: SpotifyRepository

    public init(repository: SpotifyRepository) {
        self.repository = repository
    }

    public func execute(playlistId: String, trackUris: [String], position: Int? = nil) async throws -> String {
        return try await repository.addTracksToPlaylist(
            id: playlistId,
            uris: trackUris,
            position: position
        )
    }
}