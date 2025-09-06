import Foundation

public struct SpotifyAlbum: Sendable, Equatable {
    public let id: String
    public let name: String
    public let images: [SpotifyImage]
    public let releaseDate: String
    public let totalTracks: Int
    public let artists: [SpotifyArtist]
    public let uri: String
    
    public init(
        id: String,
        name: String,
        images: [SpotifyImage],
        releaseDate: String,
        totalTracks: Int,
        artists: [SpotifyArtist],
        uri: String
    ) {
        self.id = id
        self.name = name
        self.images = images
        self.releaseDate = releaseDate
        self.totalTracks = totalTracks
        self.artists = artists
        self.uri = uri
    }
}