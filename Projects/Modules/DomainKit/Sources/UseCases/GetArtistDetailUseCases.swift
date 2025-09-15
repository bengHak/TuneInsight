import Foundation

public protocol GetArtistUseCaseProtocol {
    func execute(id: String) async throws -> SpotifyArtist
}

public protocol GetArtistsUseCaseProtocol {
    func execute(ids: [String]) async throws -> [SpotifyArtist]
}

public protocol GetArtistAlbumsUseCaseProtocol {
    func execute(artistId: String, limit: Int, offset: Int) async throws -> [SpotifyAlbum]
}

public protocol GetArtistTopTracksUseCaseProtocol {
    func execute(artistId: String, market: String) async throws -> [SpotifyTrack]
}

public final class GetArtistUseCase: GetArtistUseCaseProtocol, Sendable {
    private let repository: SpotifyRepository
    public init(repository: SpotifyRepository) { self.repository = repository }
    public func execute(id: String) async throws -> SpotifyArtist { try await repository.getArtist(id: id) }
}

public final class GetArtistsUseCase: GetArtistsUseCaseProtocol, Sendable {
    private let repository: SpotifyRepository
    public init(repository: SpotifyRepository) { self.repository = repository }
    public func execute(ids: [String]) async throws -> [SpotifyArtist] { try await repository.getArtists(ids: ids) }
}

public final class GetArtistAlbumsUseCase: GetArtistAlbumsUseCaseProtocol, Sendable {
    private let repository: SpotifyRepository
    public init(repository: SpotifyRepository) { self.repository = repository }
    public func execute(artistId: String, limit: Int = 20, offset: Int = 0) async throws -> [SpotifyAlbum] {
        try await repository.getArtistAlbums(artistId: artistId, limit: limit, offset: offset)
    }
}

public final class GetArtistTopTracksUseCase: GetArtistTopTracksUseCaseProtocol, Sendable {
    private let repository: SpotifyRepository
    public init(repository: SpotifyRepository) { self.repository = repository }
    public func execute(artistId: String, market: String = "US") async throws -> [SpotifyTrack] {
        try await repository.getArtistTopTracks(artistId: artistId, market: market)
    }
}

