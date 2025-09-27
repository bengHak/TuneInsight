import Foundation

public protocol DeletePlaylistUseCaseProtocol {
    func execute(playlistId: String) async throws
}

public final class DeletePlaylistUseCase: DeletePlaylistUseCaseProtocol, Sendable {
    private let repository: SpotifyRepository

    public init(repository: SpotifyRepository) {
        self.repository = repository
    }

    public func execute(playlistId: String) async throws {
        try await repository.deletePlaylist(id: playlistId)
    }
}