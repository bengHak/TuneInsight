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

public protocol SpotifyServiceProtocol {
    func getCurrentlyPlaying() async throws -> CurrentlyPlayingResponse
    func getRecentlyPlayed(limit: Int) async throws -> RecentlyPlayedResponse
    func getUserProfile() async throws -> UserProfile
    func play() async throws
    func pause() async throws
    func nextTrack() async throws
    func previousTrack() async throws
    func seek(to positionMs: Int) async throws
}

public final class SpotifyService: SpotifyServiceProtocol, Sendable {
    public static let shared = SpotifyService()
    
    private let apiHandler: APIHandlerProtocol
    
    public init(apiHandler: APIHandlerProtocol = APIHandler()) {
        self.apiHandler = apiHandler
    }
    
    public func getCurrentlyPlaying() async throws -> CurrentlyPlayingResponse {
        do {
            let response: CurrentlyPlayingResponse = try await apiHandler.request(SpotifyEndpoint.currentlyPlaying)
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
            let response: RecentlyPlayedResponse = try await apiHandler.request(SpotifyEndpoint.recentlyPlayed(limit: limit))
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
            let response: UserProfile = try await apiHandler.request(SpotifyEndpoint.userProfile)
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
            // PUT 요청이므로 응답 데이터가 없을 수 있음
            struct EmptyResponse: Codable, Sendable {}
            let _: EmptyResponse = try await apiHandler.request(SpotifyEndpoint.play)
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
            struct EmptyResponse: Codable, Sendable {}
            let _: EmptyResponse = try await apiHandler.request(SpotifyEndpoint.pause)
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
            struct EmptyResponse: Codable, Sendable {}
            let _: EmptyResponse = try await apiHandler.request(SpotifyEndpoint.next)
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
            struct EmptyResponse: Codable, Sendable {}
            let _: EmptyResponse = try await apiHandler.request(SpotifyEndpoint.previous)
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
            struct EmptyResponse: Codable, Sendable {}
            let _: EmptyResponse = try await apiHandler.request(SpotifyEndpoint.seek(positionMs: positionMs))
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