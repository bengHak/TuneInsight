import Foundation

public struct SpotifyAlbumTracksPage: Sendable, Equatable {
    public let items: [SpotifyAlbumTrack]
    public let limit: Int
    public let offset: Int
    public let total: Int
    public let next: String?
    public let previous: String?

    public init(
        items: [SpotifyAlbumTrack],
        limit: Int,
        offset: Int,
        total: Int,
        next: String?,
        previous: String?
    ) {
        self.items = items
        self.limit = limit
        self.offset = offset
        self.total = total
        self.next = next
        self.previous = previous
    }
}
