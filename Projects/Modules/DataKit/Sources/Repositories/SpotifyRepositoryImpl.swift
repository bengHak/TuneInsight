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
        timeRange: TopArtistTimeRange,
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
}
