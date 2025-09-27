import Foundation

public protocol RemoveTracksFromPlaylistUseCaseProtocol {
    func execute(playlistId: String, trackUris: [String], snapshotId: String?) async throws -> String
}

public final class RemoveTracksFromPlaylistUseCase: RemoveTracksFromPlaylistUseCaseProtocol, Sendable {
    private let repository: SpotifyRepository

    public init(repository: SpotifyRepository) {
        self.repository = repository
    }

    public func execute(playlistId: String, trackUris: [String], snapshotId: String? = nil) async throws -> String {
        return try await repository.removeTracksFromPlaylist(
            id: playlistId,
            tracks: trackUris,
            snapshotId: snapshotId
        )
    }
}