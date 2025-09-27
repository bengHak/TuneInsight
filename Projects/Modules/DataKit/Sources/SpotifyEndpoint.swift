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
    // Playlist endpoints
    case getUserPlaylists(limit: Int?, offset: Int?)
    case getPlaylist(id: String)
    case getPlaylistTracks(id: String, limit: Int?, offset: Int?, market: String?)
    case createPlaylist(userId: String, name: String, description: String?, public: Bool?)
    case updatePlaylist(id: String, name: String?, description: String?, public: Bool?)
    case unfollowPlaylist(id: String)
    case addTracksToPlaylist(id: String, uris: [String], position: Int?)
    case removeTracksFromPlaylist(id: String, tracks: [String], snapshotId: String?)
    case searchTracks(query: String, limit: Int?, offset: Int?, market: String?)

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
        case .getUserPlaylists:
            return "/me/playlists"
        case .getPlaylist(let id):
            return "/playlists/\(id)"
        case .getPlaylistTracks(let id, _, _, _):
            return "/playlists/\(id)/tracks"
        case .createPlaylist(let userId, _, _, _):
            return "/users/\(userId)/playlists"
        case .updatePlaylist(let id, _, _, _):
            return "/playlists/\(id)"
        case .unfollowPlaylist(let id):
            return "/playlists/\(id)/followers"
        case .addTracksToPlaylist(let id, _, _):
            return "/playlists/\(id)/tracks"
        case .removeTracksFromPlaylist(let id, _, _):
            return "/playlists/\(id)/tracks"
        case .searchTracks:
            return "/search"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .currentlyPlaying, .recentlyPlayed, .topArtists, .topTracks, .userProfile, .artist, .artists, .artistAlbums, .artistTopTracks, .albumTracks, .getUserPlaylists, .getPlaylist, .getPlaylistTracks, .searchTracks:
            return .GET
        case .play, .pause, .seek, .updatePlaylist:
            return .PUT
        case .next, .previous, .addToQueue, .createPlaylist, .addTracksToPlaylist:
            return .POST
        case .unfollowPlaylist, .removeTracksFromPlaylist:
            return .DELETE
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
        case .getUserPlaylists(let limit, let offset):
            var params: [String: Any] = [:]
            if let limit { params["limit"] = limit }
            if let offset { params["offset"] = offset }
            return params.isEmpty ? nil : params
        case .getPlaylistTracks(_, let limit, let offset, let market):
            var params: [String: Any] = [:]
            if let limit { params["limit"] = limit }
            if let offset { params["offset"] = offset }
            if let market { params["market"] = market }
            return params.isEmpty ? nil : params
        case .addTracksToPlaylist(_, let uris, let position):
            var params: [String: Any] = ["uris": uris.joined(separator: ",")]
            if let position { params["position"] = position }
            return params
        case .searchTracks(let query, let limit, let offset, let market):
            var params: [String: Any] = ["q": query, "type": "track"]
            if let limit { params["limit"] = limit }
            if let offset { params["offset"] = offset }
            if let market { params["market"] = market }
            return params
        case .currentlyPlaying, .userProfile, .play, .pause, .next, .previous, .artist, .getPlaylist, .createPlaylist, .updatePlaylist, .unfollowPlaylist, .removeTracksFromPlaylist:
            return nil
        }
    }
    
    public var bodyParameters: [String: Any]? {
        switch self {
        case .createPlaylist(_, let name, let description, let isPublic):
            var params: [String: Any] = ["name": name]
            if let description { params["description"] = description }
            if let isPublic { params["public"] = isPublic }
            return params
        case .updatePlaylist(_, let name, let description, let isPublic):
            var params: [String: Any] = [:]
            if let name { params["name"] = name }
            if let description { params["description"] = description }
            if let isPublic { params["public"] = isPublic }
            return params.isEmpty ? nil : params
        case .removeTracksFromPlaylist(_, let tracks, let snapshotId):
            var params: [String: Any] = ["tracks": tracks.map { ["uri": $0] }]
            if let snapshotId { params["snapshot_id"] = snapshotId }
            return params
        case .currentlyPlaying, .recentlyPlayed, .topArtists, .topTracks, .userProfile, .artist, .artists, .artistAlbums, .artistTopTracks, .albumTracks, .play, .pause, .next, .previous, .seek, .addToQueue, .getUserPlaylists, .getPlaylist, .getPlaylistTracks, .unfollowPlaylist, .addTracksToPlaylist, .searchTracks:
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
