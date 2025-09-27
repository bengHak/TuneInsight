import Foundation
import DomainKit

public final class SpotifyRepositoryImpl: SpotifyRepository, Sendable {
    private let service: SpotifyServiceProtocol
    
    public init(service: SpotifyServiceProtocol = SpotifyService.shared) {
        self.service = service
    }
    
    public func getCurrentPlayback() async throws -> CurrentPlayback {
        do {
            let response = try await service.getCurrentlyPlaying()
            return SpotifyMapper.toDomain(response)
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.noCurrentlyPlaying {
            throw SpotifyRepositoryError.noCurrentlyPlaying
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }
    
    public func getRecentlyPlayed(limit: Int) async throws -> [RecentTrack] {
        do {
            let response = try await service.getRecentlyPlayed(limit: limit)
            return SpotifyMapper.toDomain(response)
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }

    public func getTopArtists(
        timeRange: SpotifyTimeRange,
        limit: Int,
        offset: Int
    ) async throws -> [TopArtist] {
        do {
            let response = try await service.getTopArtists(
                timeRange: timeRange.rawValue,
                limit: limit,
                offset: offset
            )
            return SpotifyMapper.toDomain(response)
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }

    public func getTopTracks(
        timeRange: SpotifyTimeRange,
        limit: Int,
        offset: Int
    ) async throws -> [TopTrack] {
        do {
            let response = try await service.getTopTracks(
                timeRange: timeRange.rawValue,
                limit: limit,
                offset: offset
            )
            return SpotifyMapper.toDomain(response)
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }

    // MARK: - Artist Detail
    public func getArtist(id: String) async throws -> SpotifyArtist {
        do {
            let artist = try await service.getArtist(id: id)
            return SpotifyMapper.toDomainArtist(artist)
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }

    public func getArtists(ids: [String]) async throws -> [SpotifyArtist] {
        do {
            let response = try await service.getArtists(ids: ids)
            return SpotifyMapper.toDomain(response)
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }

    public func getArtistAlbums(artistId: String, limit: Int, offset: Int) async throws -> [SpotifyAlbum] {
        do {
            let response = try await service.getArtistAlbums(id: artistId, includeGroups: nil, market: nil, limit: limit, offset: offset)
            return SpotifyMapper.toDomain(response)
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }

    public func getArtistTopTracks(artistId: String, market: String) async throws -> [SpotifyTrack] {
        do {
            let response = try await service.getArtistTopTracks(id: artistId, market: market)
            return SpotifyMapper.toDomain(response)
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }

    public func getAlbumTracks(albumId: String, limit: Int, offset: Int) async throws -> SpotifyAlbumTracksPage {
        do {
            let response = try await service.getAlbumTracks(id: albumId, market: nil, limit: limit, offset: offset)
            return SpotifyMapper.toDomain(response)
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }
    
    public func play() async throws {
        do {
            try await service.play()
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }
    
    public func pause() async throws {
        do {
            try await service.pause()
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }
    
    public func nextTrack() async throws {
        do {
            try await service.nextTrack()
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }
    
    public func previousTrack() async throws {
        do {
            try await service.previousTrack()
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }
    
    public func seek(to positionMs: Int) async throws {
        do {
            try await service.seek(to: positionMs)
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }

    public func addToQueue(uri: String) async throws {
        do {
            try await service.addToQueue(uri: uri)
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }

    // MARK: - Playlist Methods

    public func getUserPlaylists(limit: Int?, offset: Int?) async throws -> PlaylistsPage {
        do {
            let response = try await service.getUserPlaylists(limit: limit, offset: offset)
            return SpotifyPlaylistMapper.toDomain(response)
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }

    public func getPlaylistDetail(id: String) async throws -> Playlist {
        do {
            let response = try await service.getPlaylist(id: id)
            return SpotifyPlaylistMapper.toDomain(response)
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }

    public func getPlaylistTracks(playlistId: String, limit: Int?, offset: Int?) async throws -> PlaylistTracksPage {
        do {
            let response = try await service.getPlaylistTracks(
                id: playlistId,
                limit: limit,
                offset: offset,
                market: nil
            )
            return SpotifyPlaylistMapper.toDomain(response)
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }

    public func getUserId() async throws -> String {
        do {
            let profile = try await service.getUserProfile()
            return profile.id
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }

    public func createPlaylist(userId: String, name: String, description: String?, isPublic: Bool?) async throws -> Playlist {
        do {
            let response = try await service.createPlaylist(
                userId: userId,
                name: name,
                description: description,
                isPublic: isPublic
            )
            return SpotifyPlaylistMapper.toDomain(response)
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }

    public func updatePlaylist(id: String, name: String?, description: String?, isPublic: Bool?) async throws {
        do {
            try await service.updatePlaylist(
                id: id,
                name: name,
                description: description,
                isPublic: isPublic
            )
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }

    public func deletePlaylist(id: String) async throws {
        do {
            try await service.unfollowPlaylist(id: id)
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }

    public func addTracksToPlaylist(id: String, uris: [String], position: Int?) async throws -> String {
        do {
            let response = try await service.addTracksToPlaylist(
                id: id,
                uris: uris,
                position: position
            )
            return response.snapshotId
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }

    public func removeTracksFromPlaylist(id: String, tracks: [String], snapshotId: String?) async throws -> String {
        do {
            let response = try await service.removeTracksFromPlaylist(
                id: id,
                tracks: tracks,
                snapshotId: snapshotId
            )
            return response.snapshotId
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }

    public func searchTracks(query: String, limit: Int?, offset: Int?, market: String?) async throws -> SearchTracksPage {
        do {
            let response = try await service.searchTracks(
                query: query,
                limit: limit,
                offset: offset,
                market: market
            )
            return SpotifyPlaylistMapper.toDomain(response)
        } catch SpotifyServiceError.unauthorized {
            throw SpotifyRepositoryError.unauthorized
        } catch SpotifyServiceError.networkError(let error) {
            throw SpotifyRepositoryError.networkError(error)
        } catch {
            throw SpotifyRepositoryError.unknown(error)
        }
    }
}
