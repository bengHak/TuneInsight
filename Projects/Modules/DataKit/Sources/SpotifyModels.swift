import Foundation

// MARK: - Currently Playing Response

public struct CurrentlyPlayingResponse: Codable, Sendable {
    public let device: Device?
    public let repeatState: String?
    public let shuffleState: Bool?
    public let context: PlaybackContext?
    public let timestamp: Int64
    public let progressMs: Int?
    public let isPlaying: Bool
    public let item: Track?
    public let currentlyPlayingType: String
    public let actions: PlaybackActions?
    
    enum CodingKeys: String, CodingKey {
        case device
        case repeatState = "repeat_state"
        case shuffleState = "shuffle_state"
        case context
        case timestamp
        case progressMs = "progress_ms"
        case isPlaying = "is_playing"
        case item
        case currentlyPlayingType = "currently_playing_type"
        case actions
    }
}

// MARK: - Device

public struct Device: Codable, Sendable {
    public let id: String?
    public let isActive: Bool
    public let isPrivateSession: Bool
    public let isRestricted: Bool
    public let name: String
    public let type: String
    public let volumePercent: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case isActive = "is_active"
        case isPrivateSession = "is_private_session"
        case isRestricted = "is_restricted"
        case name
        case type
        case volumePercent = "volume_percent"
    }
}

// MARK: - Playback Context

public struct PlaybackContext: Codable, Sendable {
    public let type: String
    public let href: String
    public let externalUrls: ExternalUrls
    public let uri: String
    
    enum CodingKeys: String, CodingKey {
        case type
        case href
        case externalUrls = "external_urls"
        case uri
    }
}

// MARK: - Playback Actions

public struct PlaybackActions: Codable, Sendable {
    public let interrupting_playback: Bool?
    public let pausing: Bool?
    public let resuming: Bool?
    public let seeking: Bool?
    public let skipping_next: Bool?
    public let skipping_prev: Bool?
    public let toggling_repeat_context: Bool?
    public let toggling_shuffle: Bool?
    public let toggling_repeat_track: Bool?
    public let transferring_playback: Bool?
}

// MARK: - Track

public struct Track: Codable, Sendable {
    public let album: Album
    public let artists: [Artist]
    public let availableMarkets: [String]?
    public let discNumber: Int
    public let durationMs: Int
    public let explicit: Bool
    public let externalIds: ExternalIds?
    public let externalUrls: ExternalUrls
    public let href: String
    public let id: String
    public let isPlayable: Bool?
    public let linkedFrom: LinkedTrack?
    public let restrictions: TrackRestriction?
    public let name: String
    public let popularity: Int
    public let previewUrl: String?
    public let trackNumber: Int
    public let type: String
    public let uri: String
    public let isLocal: Bool
    
    enum CodingKeys: String, CodingKey {
        case album
        case artists
        case availableMarkets = "available_markets"
        case discNumber = "disc_number"
        case durationMs = "duration_ms"
        case explicit
        case externalIds = "external_ids"
        case externalUrls = "external_urls"
        case href
        case id
        case isPlayable = "is_playable"
        case linkedFrom = "linked_from"
        case restrictions
        case name
        case popularity
        case previewUrl = "preview_url"
        case trackNumber = "track_number"
        case type
        case uri
        case isLocal = "is_local"
    }
}

// MARK: - Album

public struct Album: Codable, Sendable {
    public let albumType: String
    public let totalTracks: Int
    public let availableMarkets: [String]?
    public let externalUrls: ExternalUrls
    public let href: String
    public let id: String
    public let images: [SpotifyImage]
    public let name: String
    public let releaseDate: String
    public let releaseDatePrecision: String
    public let restrictions: AlbumRestriction?
    public let type: String
    public let uri: String
    public let artists: [Artist]
    
    enum CodingKeys: String, CodingKey {
        case albumType = "album_type"
        case totalTracks = "total_tracks"
        case availableMarkets = "available_markets"
        case externalUrls = "external_urls"
        case href
        case id
        case images
        case name
        case releaseDate = "release_date"
        case releaseDatePrecision = "release_date_precision"
        case restrictions
        case type
        case uri
        case artists
    }
}

// MARK: - Artist

public struct Artist: Codable, Sendable {
    public let externalUrls: ExternalUrls
    public let followers: Followers?
    public let genres: [String]?
    public let href: String
    public let id: String
    public let images: [SpotifyImage]?
    public let name: String
    public let popularity: Int?
    public let type: String
    public let uri: String
    
    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case followers
        case genres
        case href
        case id
        case images
        case name
        case popularity
        case type
        case uri
    }
}

// MARK: - Spotify Image

public struct SpotifyImage: Codable, Sendable {
    public let url: String
    public let height: Int?
    public let width: Int?
}

// MARK: - External URLs

public struct ExternalUrls: Codable, Sendable {
    public let spotify: String
}

// MARK: - External IDs

public struct ExternalIds: Codable, Sendable {
    public let isrc: String?
    public let ean: String?
    public let upc: String?
}

// MARK: - Followers

public struct Followers: Codable, Sendable {
    public let href: String?
    public let total: Int
}

// MARK: - Linked Track

public struct LinkedTrack: Codable, Sendable {
    public let externalUrls: ExternalUrls
    public let href: String
    public let id: String
    public let type: String
    public let uri: String
    
    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case href
        case id
        case type
        case uri
    }
}

// MARK: - Restrictions

public struct TrackRestriction: Codable, Sendable {
    public let reason: String
}

public struct AlbumRestriction: Codable, Sendable {
    public let reason: String
}

// MARK: - Recently Played Response

public struct RecentlyPlayedResponse: Codable, Sendable {
    public let items: [PlayHistory]
    public let next: String?
    public let cursors: Cursor?
    public let limit: Int
    public let href: String
    public let total: Int?
}

// MARK: - Play History

public struct PlayHistory: Codable, Sendable {
    public let track: Track
    public let playedAt: String
    public let context: PlaybackContext?
    
    enum CodingKeys: String, CodingKey {
        case track
        case playedAt = "played_at"
        case context
    }
}

// MARK: - Cursor

public struct Cursor: Codable, Sendable {
    public let after: String?
    public let before: String?
}

// MARK: - User Profile

public struct UserProfile: Codable, Sendable {
    public let country: String?
    public let displayName: String?
    public let email: String?
    public let explicitContent: ExplicitContent?
    public let externalUrls: ExternalUrls
    public let followers: Followers
    public let href: String
    public let id: String
    public let images: [SpotifyImage]
    public let product: String?
    public let type: String
    public let uri: String
    
    enum CodingKeys: String, CodingKey {
        case country
        case displayName = "display_name"
        case email
        case explicitContent = "explicit_content"
        case externalUrls = "external_urls"
        case followers
        case href
        case id
        case images
        case product
        case type
        case uri
    }
}

// MARK: - Explicit Content

public struct ExplicitContent: Codable, Sendable {
    public let filterEnabled: Bool
    public let filterLocked: Bool
    
    enum CodingKeys: String, CodingKey {
        case filterEnabled = "filter_enabled"
        case filterLocked = "filter_locked"
    }
}
