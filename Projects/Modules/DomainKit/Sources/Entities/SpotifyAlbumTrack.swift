import Foundation
import FoundationKit

public struct SpotifyAlbumTrack: Sendable, Equatable {
    public let id: String
    public let name: String
    public let discNumber: Int
    public let trackNumber: Int
    public let durationMs: Int
    public let explicit: Bool
    public let uri: String
    public let previewUrl: String?
    public let isPlayable: Bool?
    public let isLocal: Bool
    public let artists: [SpotifyArtist]
    public let availableMarkets: [String]
    public let restrictions: TrackRestriction?

    public init(
        id: String,
        name: String,
        discNumber: Int,
        trackNumber: Int,
        durationMs: Int,
        explicit: Bool,
        uri: String,
        previewUrl: String?,
        isPlayable: Bool?,
        isLocal: Bool,
        artists: [SpotifyArtist],
        availableMarkets: [String],
        restrictions: TrackRestriction?
    ) {
        self.id = id
        self.name = name
        self.discNumber = discNumber
        self.trackNumber = trackNumber
        self.durationMs = durationMs
        self.explicit = explicit
        self.uri = uri
        self.previewUrl = previewUrl
        self.isPlayable = isPlayable
        self.isLocal = isLocal
        self.artists = artists
        self.availableMarkets = availableMarkets
        self.restrictions = restrictions
    }
}

public extension SpotifyAlbumTrack {
    var durationFormatted: String {
        let seconds = durationMs / 1000
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }

    var artistNames: String {
        artists.map { $0.name }.joined(separator: ", ")
    }

    var availableMarketsDescription: String {
        guard !availableMarkets.isEmpty else { return "-" }
        return "album.availableMarketsCount".localizedFormat(availableMarkets.count)
    }
}
