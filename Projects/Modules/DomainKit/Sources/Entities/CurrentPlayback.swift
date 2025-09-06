import Foundation

public struct CurrentPlayback: Sendable, Equatable {
    public let track: SpotifyTrack?
    public let isPlaying: Bool
    public let progressMs: Int?
    public let device: PlaybackDevice?
    public let shuffleState: Bool
    public let repeatState: RepeatState
    public let timestamp: Int64
    
    public init(
        track: SpotifyTrack?,
        isPlaying: Bool,
        progressMs: Int?,
        device: PlaybackDevice?,
        shuffleState: Bool,
        repeatState: RepeatState,
        timestamp: Int64
    ) {
        self.track = track
        self.isPlaying = isPlaying
        self.progressMs = progressMs
        self.device = device
        self.shuffleState = shuffleState
        self.repeatState = repeatState
        self.timestamp = timestamp
    }
}

public struct PlaybackDevice: Sendable, Equatable {
    public let id: String?
    public let name: String
    public let type: String
    public let isActive: Bool
    public let volumePercent: Int?
    
    public init(
        id: String?,
        name: String,
        type: String,
        isActive: Bool,
        volumePercent: Int?
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.isActive = isActive
        self.volumePercent = volumePercent
    }
}

public enum RepeatState: String, CaseIterable, Sendable {
    case off = "off"
    case track = "track"
    case context = "context"
}

public extension CurrentPlayback {
    var isActive: Bool {
        return track != nil
    }
    
    var trackName: String {
        return track?.name ?? "알 수 없는 곡"
    }
    
    var artistName: String {
        return track?.primaryArtist ?? "알 수 없는 아티스트"
    }
    
    var albumName: String {
        return track?.album.name ?? "알 수 없는 앨범"
    }
    
    var albumImageUrl: String? {
        return track?.albumImageUrl
    }
    
    var progressPercentage: Float {
        guard let progressMs = progressMs,
              let durationMs = track?.durationMs,
              durationMs > 0 else {
            return 0.0
        }
        return Float(progressMs) / Float(durationMs)
    }
    
    var formattedProgress: String {
        guard let progressMs = progressMs else { return "0:00" }
        let seconds = progressMs / 1000
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}