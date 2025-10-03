import Foundation
import FoundationKit

public struct SpotifyTrack: Sendable, Equatable {
    public let id: String
    public let name: String
    public let artists: [SpotifyArtist]
    public let album: SpotifyAlbum
    public let durationMs: Int
    public let popularity: Int
    public let previewUrl: String?
    public let uri: String
    
    public init(
        id: String,
        name: String,
        artists: [SpotifyArtist],
        album: SpotifyAlbum,
        durationMs: Int,
        popularity: Int,
        previewUrl: String?,
        uri: String
    ) {
        self.id = id
        self.name = name
        self.artists = artists
        self.album = album
        self.durationMs = durationMs
        self.popularity = popularity
        self.previewUrl = previewUrl
        self.uri = uri
    }
}

public extension SpotifyTrack {
    var primaryArtist: String {
        return artists.first?.name ?? "artist.unknownName".localized()
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
    
    var artistNames: String {
        return artists.map { $0.name }.joined(separator: ", ")
    }
}
