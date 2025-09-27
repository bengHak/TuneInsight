import Foundation
import FoundationKit

public enum SpotifyEndpoint: APIEndpoint {
    case currentlyPlaying
    case recentlyPlayed(limit: Int? = nil)
    case topArtists(timeRange: String, limit: Int, offset: Int)
    case topTracks(timeRange: String, limit: Int, offset: Int)
    case artist(id: String)
    case artists(ids: [String])
    case artistAlbums(id: String, includeGroups: String?, market: String?, limit: Int?, offset: Int?)
    case albumTracks(id: String, market: String?, limit: Int?, offset: Int?)
    case artistTopTracks(id: String, market: String)
    case userProfile
    case play
    case pause
    case next
    case previous
    case seek(positionMs: Int)
    case addToQueue(uri: String)
    
    public var baseURL: String {
        return "https://api.spotify.com/v1"
    }
    
    public var path: String {
        switch self {
        case .currentlyPlaying:
            return "/me/player/currently-playing"
        case .recentlyPlayed:
            return "/me/player/recently-played"
        case .topArtists:
            return "/me/top/artists"
        case .topTracks:
            return "/me/top/tracks"
        case .artist(let id):
            return "/artists/\(id)"
        case .artists:
            return "/artists"
        case .artistAlbums(let id, _, _, _, _):
            return "/artists/\(id)/albums"
        case .artistTopTracks(let id, _):
            return "/artists/\(id)/top-tracks"
        case .albumTracks(let id, _, _, _):
            return "/albums/\(id)/tracks"
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
        case .addToQueue:
            return "/me/player/queue"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .currentlyPlaying, .recentlyPlayed, .topArtists, .topTracks, .userProfile, .artist, .artists, .artistAlbums, .artistTopTracks, .albumTracks:
            return .GET
        case .play, .pause, .seek:
            return .PUT
        case .next, .previous, .addToQueue:
            return .POST
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
        case .topArtists(let timeRange, let limit, let offset):
            return [
                "time_range": timeRange,
                "limit": limit,
                "offset": offset
            ]
        case .topTracks(let timeRange, let limit, let offset):
            return [
                "time_range": timeRange,
                "limit": limit,
                "offset": offset
            ]
        case .artists(let ids):
            return ["ids": ids.joined(separator: ",")]
        case .artistAlbums(_, let includeGroups, let market, let limit, let offset):
            var params: [String: Any] = [:]
            if let includeGroups { params["include_groups"] = includeGroups }
            if let market { params["market"] = market }
            if let limit { params["limit"] = limit }
            if let offset { params["offset"] = offset }
            return params.isEmpty ? nil : params
        case .albumTracks(_, let market, let limit, let offset):
            var params: [String: Any] = [:]
            if let market { params["market"] = market }
            if let limit { params["limit"] = limit }
            if let offset { params["offset"] = offset }
            return params.isEmpty ? nil : params
        case .artistTopTracks(_, let market):
            return ["market": market]
        case .seek(let positionMs):
            return ["position_ms": positionMs]
        case .addToQueue(let uri):
            return ["uri": uri]
        case .currentlyPlaying, .userProfile, .play, .pause, .next, .previous, .artist:
            return nil
        }
    }
    
    public var bodyParameters: [String: Any]? {
        switch self {
        case .currentlyPlaying, .recentlyPlayed, .topArtists, .topTracks, .userProfile, .artist, .artists, .artistAlbums, .artistTopTracks, .albumTracks, .play, .pause, .next, .previous, .seek, .addToQueue:
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
