import Foundation

public enum SpotifyServiceError: Error {
    case noCurrentlyPlaying
    case unauthorized
    case networkError(Error)
    case apiError(APIError)
    
    public var localizedDescription: String {
        switch self {
        case .noCurrentlyPlaying:
            return "현재 재생 중인 곡이 없습니다."
        case .unauthorized:
            return "Spotify 인증이 필요합니다."
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .apiError(let error):
            return "API 오류: \(error)"
        }
    }
}

public protocol SpotifyServiceProtocol: Sendable {
    func getCurrentlyPlaying() async throws -> CurrentlyPlayingResponse
    func getRecentlyPlayed(limit: Int) async throws -> RecentlyPlayedResponse
    func getTopArtists(timeRange: String, limit: Int, offset: Int) async throws -> TopArtistsResponse
    func getArtist(id: String) async throws -> Artist
    func getArtists(ids: [String]) async throws -> ArtistsResponse
    func getArtistAlbums(id: String, includeGroups: String?, market: String?, limit: Int?, offset: Int?) async throws -> ArtistAlbumsResponse
    func getArtistTopTracks(id: String, market: String) async throws -> ArtistTopTracksResponse
    func getAlbumTracks(id: String, market: String?, limit: Int?, offset: Int?) async throws -> AlbumTracksResponse
    func getUserProfile() async throws -> UserProfile
    func play() async throws
    func pause() async throws
    func nextTrack() async throws
    func previousTrack() async throws
    func seek(to positionMs: Int) async throws
    func addToQueue(uri: String) async throws
}

public final class SpotifyService: SpotifyServiceProtocol, Sendable {
    public static let shared = SpotifyService()
    
    private let apiHandler: APIHandlerProtocol
    
    public init(apiHandler: APIHandlerProtocol = APIHandler()) {
        self.apiHandler = apiHandler
    }
    
    public func getCurrentlyPlaying() async throws -> CurrentlyPlayingResponse {
        do {
            // Spotify API는 현재 재생 중인 곡이 없을 때 HTTP 204 (No Content)를 반환
            // APIHandler에서 204의 경우 nil을 반환하도록 처리됨
            guard let response: CurrentlyPlayingResponse = try await apiHandler.request(SpotifyEndpoint.currentlyPlaying) else {
                throw SpotifyServiceError.noCurrentlyPlaying
            }
            return response
        } catch APIError.unauthorized {
            throw SpotifyServiceError.unauthorized
        } catch let error as APIError {
            throw SpotifyServiceError.apiError(error)
        } catch {
            throw SpotifyServiceError.networkError(error)
        }
    }
    
    public func getRecentlyPlayed(limit: Int = 20) async throws -> RecentlyPlayedResponse {
        do {
            guard let response: RecentlyPlayedResponse = try await apiHandler.request(SpotifyEndpoint.recentlyPlayed(limit: limit)) else {
                throw SpotifyServiceError.networkError(APIError.noData)
            }
            return response
        } catch APIError.unauthorized {
            throw SpotifyServiceError.unauthorized
        } catch let error as APIError {
            throw SpotifyServiceError.apiError(error)
        } catch {
            throw SpotifyServiceError.networkError(error)
        }
    }
    
    public func getTopArtists(timeRange: String, limit: Int, offset: Int) async throws -> TopArtistsResponse {
        do {
            guard let response: TopArtistsResponse = try await apiHandler.request(
                SpotifyEndpoint.topArtists(timeRange: timeRange, limit: limit, offset: offset)
            ) else {
                throw SpotifyServiceError.networkError(APIError.noData)
            }
            return response
        } catch APIError.unauthorized {
            throw SpotifyServiceError.unauthorized
        } catch let error as APIError {
            throw SpotifyServiceError.apiError(error)
        } catch {
            throw SpotifyServiceError.networkError(error)
        }
    }

    public func getArtist(id: String) async throws -> Artist {
        do {
            guard let response: Artist = try await apiHandler.request(SpotifyEndpoint.artist(id: id)) else {
                throw SpotifyServiceError.networkError(APIError.noData)
            }
            return response
        } catch APIError.unauthorized {
            throw SpotifyServiceError.unauthorized
        } catch let error as APIError {
            throw SpotifyServiceError.apiError(error)
        } catch {
            throw SpotifyServiceError.networkError(error)
        }
    }

    public func getArtists(ids: [String]) async throws -> ArtistsResponse {
        do {
            guard let response: ArtistsResponse = try await apiHandler.request(SpotifyEndpoint.artists(ids: ids)) else {
                throw SpotifyServiceError.networkError(APIError.noData)
            }
            return response
        } catch APIError.unauthorized {
            throw SpotifyServiceError.unauthorized
        } catch let error as APIError {
            throw SpotifyServiceError.apiError(error)
        } catch {
            throw SpotifyServiceError.networkError(error)
        }
    }

    public func getArtistAlbums(id: String, includeGroups: String? = nil, market: String? = nil, limit: Int? = nil, offset: Int? = nil) async throws -> ArtistAlbumsResponse {
        do {
            guard let response: ArtistAlbumsResponse = try await apiHandler.request(
                SpotifyEndpoint.artistAlbums(id: id, includeGroups: includeGroups, market: market, limit: limit, offset: offset)
            ) else {
                throw SpotifyServiceError.networkError(APIError.noData)
            }
            return response
        } catch APIError.unauthorized {
            throw SpotifyServiceError.unauthorized
        } catch let error as APIError {
            throw SpotifyServiceError.apiError(error)
        } catch {
            throw SpotifyServiceError.networkError(error)
        }
    }

    public func getArtistTopTracks(id: String, market: String) async throws -> ArtistTopTracksResponse {
        do {
            guard let response: ArtistTopTracksResponse = try await apiHandler.request(
                SpotifyEndpoint.artistTopTracks(id: id, market: market)
            ) else {
                throw SpotifyServiceError.networkError(APIError.noData)
            }
            return response
        } catch APIError.unauthorized {
            throw SpotifyServiceError.unauthorized
        } catch let error as APIError {
            throw SpotifyServiceError.apiError(error)
        } catch {
            throw SpotifyServiceError.networkError(error)
        }
    }

    public func getAlbumTracks(id: String, market: String? = nil, limit: Int? = nil, offset: Int? = nil) async throws -> AlbumTracksResponse {
        do {
            guard let response: AlbumTracksResponse = try await apiHandler.request(
                SpotifyEndpoint.albumTracks(id: id, market: market, limit: limit, offset: offset)
            ) else {
                throw SpotifyServiceError.networkError(APIError.noData)
            }
            return response
        } catch APIError.unauthorized {
            throw SpotifyServiceError.unauthorized
        } catch let error as APIError {
            throw SpotifyServiceError.apiError(error)
        } catch {
            throw SpotifyServiceError.networkError(error)
        }
    }

    public func getUserProfile() async throws -> UserProfile {
        do {
            guard let response: UserProfile = try await apiHandler.request(SpotifyEndpoint.userProfile) else {
                throw SpotifyServiceError.networkError(APIError.noData)
            }
            return response
        } catch APIError.unauthorized {
            throw SpotifyServiceError.unauthorized
        } catch let error as APIError {
            throw SpotifyServiceError.apiError(error)
        } catch {
            throw SpotifyServiceError.networkError(error)
        }
    }
    
    public func play() async throws {
        do {
            // PUT 요청이므로 응답 데이터가 없을 수 있음 (nil 반환 허용)
            let _: String? = try await apiHandler.requestWithoutContentTypeValidation(SpotifyEndpoint.play)
            // nil 반환도 정상적인 경우로 처리
        } catch APIError.unauthorized {
            throw SpotifyServiceError.unauthorized
        } catch let error as APIError {
            throw SpotifyServiceError.apiError(error)
        } catch {
            throw SpotifyServiceError.networkError(error)
        }
    }
    
    public func pause() async throws {
        do {
            let _: String? = try await apiHandler.requestWithoutContentTypeValidation(SpotifyEndpoint.pause)
            // nil 반환도 정상적인 경우로 처리
        } catch APIError.unauthorized {
            throw SpotifyServiceError.unauthorized
        } catch let error as APIError {
            throw SpotifyServiceError.apiError(error)
        } catch {
            throw SpotifyServiceError.networkError(error)
        }
    }
    
    public func nextTrack() async throws {
        do {
            let _: String? = try await apiHandler.requestWithoutContentTypeValidation(SpotifyEndpoint.next)
            // nil 반환도 정상적인 경우로 처리
        } catch APIError.unauthorized {
            throw SpotifyServiceError.unauthorized
        } catch let error as APIError {
            throw SpotifyServiceError.apiError(error)
        } catch {
            throw SpotifyServiceError.networkError(error)
        }
    }
    
    public func previousTrack() async throws {
        do {
            let _: String? = try await apiHandler.requestWithoutContentTypeValidation(SpotifyEndpoint.previous)
            // nil 반환도 정상적인 경우로 처리
        } catch APIError.unauthorized {
            throw SpotifyServiceError.unauthorized
        } catch let error as APIError {
            throw SpotifyServiceError.apiError(error)
        } catch {
            throw SpotifyServiceError.networkError(error)
        }
    }
    
    public func seek(to positionMs: Int) async throws {
        do {
            let _: String? = try await apiHandler.requestWithoutContentTypeValidation(SpotifyEndpoint.seek(positionMs: positionMs))
            // nil 반환도 정상적인 경우로 처리
        } catch APIError.unauthorized {
            throw SpotifyServiceError.unauthorized
        } catch let error as APIError {
            throw SpotifyServiceError.apiError(error)
        } catch {
            throw SpotifyServiceError.networkError(error)
        }
    }

    public func addToQueue(uri: String) async throws {
        do {
            let _: String? = try await apiHandler.requestWithoutContentTypeValidation(
                SpotifyEndpoint.addToQueue(uri: uri)
            )
        } catch APIError.unauthorized {
            throw SpotifyServiceError.unauthorized
        } catch let error as APIError {
            throw SpotifyServiceError.apiError(error)
        } catch {
            throw SpotifyServiceError.networkError(error)
        }
    }
}

// MARK: - Helper Extensions

public extension CurrentlyPlayingResponse {
    var isActive: Bool {
        return item != nil
    }
    
    var trackName: String {
        return item?.name ?? "알 수 없는 곡"
    }
    
    var artistName: String {
        return item?.artists.first?.name ?? "알 수 없는 아티스트"
    }
    
    var albumName: String {
        return item?.album.name ?? "알 수 없는 앨범"
    }
    
    var albumImageUrl: String? {
        return item?.album.images.first?.url
    }
    
    var progressPercentage: Float {
        guard let progressMs = progressMs,
              let durationMs = item?.durationMs,
              durationMs > 0 else {
            return 0.0
        }
        return Float(progressMs) / Float(durationMs)
    }
}

public extension Track {
    var primaryArtist: String {
        return artists.first?.name ?? "알 수 없는 아티스트"
    }
    
    var albumImageUrl: String? {
        return album.images.first?.url
    }
    
    var durationFormatted: String {
        let seconds = durationMs / 1000
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}
