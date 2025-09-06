import Foundation

public struct RecentTrack: Sendable, Equatable {
    public let track: SpotifyTrack
    public let playedAt: Date
    public let context: PlaybackContext?
    
    public init(
        track: SpotifyTrack,
        playedAt: Date,
        context: PlaybackContext? = nil
    ) {
        self.track = track
        self.playedAt = playedAt
        self.context = context
    }
}

public struct PlaybackContext: Sendable, Equatable {
    public let type: String
    public let uri: String
    
    public init(type: String, uri: String) {
        self.type = type
        self.uri = uri
    }
}