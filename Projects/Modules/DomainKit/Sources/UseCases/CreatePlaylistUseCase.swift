import Foundation

public protocol CreatePlaylistUseCaseProtocol {
    func execute(name: String, description: String?, isPublic: Bool?) async throws -> Playlist
}

public final class CreatePlaylistUseCase: CreatePlaylistUseCaseProtocol, Sendable {
    private let repository: SpotifyRepository

    public init(repository: SpotifyRepository) {
        self.repository = repository
    }

    public func execute(name: String, description: String? = nil, isPublic: Bool? = true) async throws -> Playlist {
        // First, get the user profile to get the userId
        let userId = try await repository.getUserId()

        // Create the playlist
        return try await repository.createPlaylist(
            userId: userId,
            name: name,
            description: description,
            isPublic: isPublic
        )
    }
}