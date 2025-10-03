import Foundation
import FoundationKit

public enum SpotifyRepositoryError: Error {
    case noCurrentlyPlaying
    case unauthorized
    case networkError(Error)
    case unknown(Error)
    
    public var localizedDescription: String {
        switch self {
        case .noCurrentlyPlaying:
            return "player.noCurrentTrack".localized()
        case .unauthorized:
            return "auth.spotifyRequired".localized()
        case .networkError(let error):
            return "error.networkWithDetail".localizedFormat(error.localizedDescription)
        case .unknown(let error):
            return "error.unknownWithDetail".localizedFormat(error.localizedDescription)
        }
    }
}

public protocol SpotifyRepository: Sendable {
    func getCurrentPlayback() async throws -> CurrentPlayback
    func getRecentlyPlayed(limit: Int) async throws -> [RecentTrack]
    func getTopArtists(
        timeRange: SpotifyTimeRange,
        limit: Int,
        offset: Int
    ) async throws -> [TopArtist]
    func getTopTracks(
        timeRange: SpotifyTimeRange,
        limit: Int,
        offset: Int
    ) async throws -> [TopTrack]
    // Artist Detail
    func getArtist(id: String) async throws -> SpotifyArtist
    func getArtists(ids: [String]) async throws -> [SpotifyArtist]
    func getArtistAlbums(artistId: String, limit: Int, offset: Int) async throws -> [SpotifyAlbum]
    func getArtistTopTracks(artistId: String, market: String) async throws -> [SpotifyTrack]
    func getAlbumTracks(albumId: String, limit: Int, offset: Int) async throws -> SpotifyAlbumTracksPage
    func play() async throws
    func pause() async throws
    func nextTrack() async throws
    func previousTrack() async throws
    func seek(to positionMs: Int) async throws
    func addToQueue(uri: String) async throws
    // Playlist methods
    func getUserPlaylists(limit: Int?, offset: Int?) async throws -> PlaylistsPage
    func getPlaylistDetail(id: String) async throws -> Playlist
    func getPlaylistTracks(playlistId: String, limit: Int?, offset: Int?) async throws -> PlaylistTracksPage
    func getUserId() async throws -> String
    func createPlaylist(userId: String, name: String, description: String?, isPublic: Bool?) async throws -> Playlist
    func updatePlaylist(id: String, name: String?, description: String?, isPublic: Bool?) async throws
    func deletePlaylist(id: String) async throws
    func addTracksToPlaylist(id: String, uris: [String], position: Int?) async throws -> String
    func removeTracksFromPlaylist(id: String, tracks: [String], snapshotId: String?) async throws -> String
    func searchTracks(query: String, limit: Int?, offset: Int?, market: String?) async throws -> SearchTracksPage
}
