import Foundation

public struct TopTrack: Sendable, Equatable {
    public let track: SpotifyTrack
    public let rank: Int?

    public init(track: SpotifyTrack, rank: Int? = nil) {
        self.track = track
        self.rank = rank
    }
}

public extension TopTrack {
    var id: String { track.id }
    var name: String { track.name }
    var artists: [SpotifyArtist] { track.artists }
    var album: SpotifyAlbum { track.album }
    var durationMs: Int { track.durationMs }
    var popularity: Int? { track.popularity }
    var uri: String { track.uri }
    var previewUrl: String? { track.previewUrl }

    var primaryArtistName: String { artists.first?.name ?? "" }
}
