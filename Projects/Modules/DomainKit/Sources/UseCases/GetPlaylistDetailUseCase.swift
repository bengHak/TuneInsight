import Foundation

public protocol GetPlaylistDetailUseCaseProtocol {
    func execute(playlistId: String) async throws -> Playlist
    func getPlaylistTracks(playlistId: String, limit: Int?, offset: Int?) async throws -> PlaylistTracksPage
}

public final class GetPlaylistDetailUseCase: GetPlaylistDetailUseCaseProtocol, Sendable {
    private let repository: SpotifyRepository

    public init(repository: SpotifyRepository) {
        self.repository = repository
    }

    public func execute(playlistId: String) async throws -> Playlist {
        return try await repository.getPlaylistDetail(id: playlistId)
    }

    public func getPlaylistTracks(playlistId: String, limit: Int? = 50, offset: Int? = 0) async throws -> PlaylistTracksPage {
        return try await repository.getPlaylistTracks(playlistId: playlistId, limit: limit, offset: offset)
    }
}