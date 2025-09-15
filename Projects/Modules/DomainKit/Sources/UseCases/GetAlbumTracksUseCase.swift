import Foundation

public protocol GetAlbumTracksUseCaseProtocol: Sendable {
    func execute(albumId: String, limit: Int, offset: Int) async throws -> SpotifyAlbumTracksPage
}

public final class GetAlbumTracksUseCase: GetAlbumTracksUseCaseProtocol, Sendable {
    private let repository: SpotifyRepository

    public init(repository: SpotifyRepository) {
        self.repository = repository
    }

    public func execute(albumId: String, limit: Int = 20, offset: Int = 0) async throws -> SpotifyAlbumTracksPage {
        try await repository.getAlbumTracks(albumId: albumId, limit: limit, offset: offset)
    }
}
