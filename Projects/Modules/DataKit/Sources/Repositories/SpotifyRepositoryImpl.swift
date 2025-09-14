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
}
