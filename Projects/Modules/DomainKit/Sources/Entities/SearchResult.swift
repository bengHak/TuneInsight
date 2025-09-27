import Foundation

public struct SearchTrackResult: Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let artists: [String]
    public let album: String
    public let albumImageUrl: String?
    public let durationMs: Int
    public let uri: String
    public let popularity: Int?
    public let explicit: Bool
    public let previewUrl: String?

    public init(
        id: String,
        name: String,
        artists: [String],
        album: String,
        albumImageUrl: String? = nil,
        durationMs: Int,
        uri: String,
        popularity: Int? = nil,
        explicit: Bool,
        previewUrl: String? = nil
    ) {
        self.id = id
        self.name = name
        self.artists = artists
        self.album = album
        self.albumImageUrl = albumImageUrl
        self.durationMs = durationMs
        self.uri = uri
        self.popularity = popularity
        self.explicit = explicit
        self.previewUrl = previewUrl
    }

    public var formattedDuration: String {
        let totalSeconds = durationMs / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    public var artistsText: String {
        artists.joined(separator: ", ")
    }
}

public struct SearchTracksPage: Sendable {
    public let items: [SearchTrackResult]
    public let total: Int
    public let limit: Int
    public let offset: Int
    public let hasNext: Bool
    public let hasPrevious: Bool

    public init(
        items: [SearchTrackResult],
        total: Int,
        limit: Int,
        offset: Int,
        hasNext: Bool,
        hasPrevious: Bool
    ) {
        self.items = items
        self.total = total
        self.limit = limit
        self.offset = offset
        self.hasNext = hasNext
        self.hasPrevious = hasPrevious
    }
}