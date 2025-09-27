import Foundation

public protocol UpdatePlaylistUseCaseProtocol {
    func execute(playlistId: String, name: String?, description: String?, isPublic: Bool?) async throws
}

public final class UpdatePlaylistUseCase: UpdatePlaylistUseCaseProtocol, Sendable {
    private let repository: SpotifyRepository

    public init(repository: SpotifyRepository) {
        self.repository = repository
    }

    public func execute(playlistId: String, name: String? = nil, description: String? = nil, isPublic: Bool? = nil) async throws {
        try await repository.updatePlaylist(
            id: playlistId,
            name: name,
            description: description,
            isPublic: isPublic
        )
    }
}