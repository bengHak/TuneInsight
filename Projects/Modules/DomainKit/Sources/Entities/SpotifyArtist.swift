import Foundation

public struct SpotifyArtist: Sendable, Equatable {
    public let id: String
    public let name: String
    public let uri: String
    public let images: [SpotifyImage]
    public let genres: [String]
    public let popularity: Int?
    
    public init(
        id: String,
        name: String,
        uri: String,
        images: [SpotifyImage] = [],
        genres: [String] = [],
        popularity: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.uri = uri
        self.images = images
        self.genres = genres
        self.popularity = popularity
    }
}