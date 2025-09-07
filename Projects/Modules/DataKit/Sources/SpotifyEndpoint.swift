import Foundation
import FoundationKit

public enum SpotifyEndpoint: APIEndpoint {
    case currentlyPlaying
    case recentlyPlayed(limit: Int? = nil)
    case userProfile
    case play
    case pause
    case next
    case previous
    case seek(positionMs: Int)
    
    public var baseURL: String {
        return "https://api.spotify.com/v1"
    }
    
    public var path: String {
        switch self {
        case .currentlyPlaying:
            return "/me/player/currently-playing"
        case .recentlyPlayed:
            return "/me/player/recently-played"
        case .userProfile:
            return "/me"
        case .play:
            return "/me/player/play"
        case .pause:
            return "/me/player/pause"
        case .next:
            return "/me/player/next"
        case .previous:
            return "/me/player/previous"
        case .seek:
            return "/me/player/seek"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .currentlyPlaying, .recentlyPlayed, .userProfile:
            return .GET
        case .play, .pause, .next, .previous, .seek:
            return .PUT
        }
    }
    
    public var parameters: [String: Any]? {
        return nil
    }
    
    public var queryParameters: [String: Any]? {
        switch self {
        case .recentlyPlayed(let limit):
            if let limit = limit {
                return ["limit": limit]
            }
            return nil
        case .seek(let positionMs):
            return ["position_ms": positionMs]
        case .currentlyPlaying, .userProfile, .play, .pause, .next, .previous:
            return nil
        }
    }
    
    public var bodyParameters: [String: Any]? {
        switch self {
        case .currentlyPlaying, .recentlyPlayed, .userProfile, .play, .pause, .next, .previous, .seek:
            return nil
        }
    }
    
    public var headers: [String: String]? {
        guard let accessToken = getAccessToken() else {
            print("[SpotifyEndpoint] 액세스 토큰을 찾을 수 없습니다.")
            return nil
        }
        
        return [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json"
        ]
    }
    
    private func getAccessToken() -> String? {
        do {
            return try TokenStorage.shared.getCurrentAccessToken()
        } catch {
            print("[SpotifyEndpoint] 토큰 조회 실패: \(error)")
            return nil
        }
    }
}
