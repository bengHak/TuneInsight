import Foundation

// MARK: - Playlist Response
public struct PlaylistsResponse: Codable {
    public let href: String
    public let limit: Int
    public let next: String?
    public let offset: Int
    public let previous: String?
    public let total: Int
    public let items: [PlaylistDTO]
}

// MARK: - Playlist DTO
public struct PlaylistDTO: Codable {
    public let collaborative: Bool
    public let description: String?
    public let externalUrls: ExternalUrls
    public let href: String
    public let id: String
    public let images: [SpotifyImage]?
    public let name: String
    public let owner: PlaylistOwnerDTO
    public let `public`: Bool?
    public let snapshotId: String
    public let tracks: PlaylistTracksInfoDTO
    public let type: String
    public let uri: String

    enum CodingKeys: String, CodingKey {
        case collaborative, description, href, id, images, name, owner, type, uri
        case externalUrls = "external_urls"
        case `public` = "public"
        case snapshotId = "snapshot_id"
        case tracks
    }
}

// MARK: - Playlist Owner
public struct PlaylistOwnerDTO: Codable {
    public let displayName: String?
    public let externalUrls: ExternalUrls
    public let href: String
    public let id: String
    public let type: String
    public let uri: String

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case externalUrls = "external_urls"
        case href, id, type, uri
    }
}

// MARK: - Playlist Tracks Info
public struct PlaylistTracksInfoDTO: Codable {
    public let href: String
    public let total: Int
}

// MARK: - Playlist Tracks Response
public struct PlaylistTracksResponse: Codable {
    public let href: String
    public let limit: Int
    public let next: String?
    public let offset: Int
    public let previous: String?
    public let total: Int
    public let items: [PlaylistTrackDTO]
}

// MARK: - Playlist Track Item
public struct PlaylistTrackDTO: Codable {
    public let addedAt: String?
    public let addedBy: PlaylistOwnerDTO?
    public let isLocal: Bool
    public let track: TrackDTO

    enum CodingKeys: String, CodingKey {
        case addedAt = "added_at"
        case addedBy = "added_by"
        case isLocal = "is_local"
        case track
    }
}

// MARK: - Track DTO
public struct TrackDTO: Codable {
    public let album: SimplifiedAlbumDTO?
    public let artists: [Artist]
    public let availableMarkets: [String]?
    public let discNumber: Int
    public let durationMs: Int
    public let explicit: Bool
    public let externalIds: ExternalIds?
    public let externalUrls: ExternalUrls
    public let href: String
    public let id: String
    public let isLocal: Bool?
    public let name: String
    public let popularity: Int?
    public let previewUrl: String?
    public let trackNumber: Int
    public let type: String
    public let uri: String

    enum CodingKeys: String, CodingKey {
        case album, artists, explicit, href, id, name, popularity, type, uri
        case availableMarkets = "available_markets"
        case discNumber = "disc_number"
        case durationMs = "duration_ms"
        case externalIds = "external_ids"
        case externalUrls = "external_urls"
        case isLocal = "is_local"
        case previewUrl = "preview_url"
        case trackNumber = "track_number"
    }
}

// MARK: - Simplified Album DTO
public struct SimplifiedAlbumDTO: Codable {
    public let albumType: String
    public let artists: [Artist]
    public let availableMarkets: [String]?
    public let externalUrls: ExternalUrls
    public let href: String
    public let id: String
    public let images: [SpotifyImage]
    public let name: String
    public let releaseDate: String
    public let releaseDatePrecision: String
    public let type: String
    public let uri: String

    enum CodingKeys: String, CodingKey {
        case artists, href, id, images, name, type, uri
        case albumType = "album_type"
        case availableMarkets = "available_markets"
        case externalUrls = "external_urls"
        case releaseDate = "release_date"
        case releaseDatePrecision = "release_date_precision"
    }
}


// MARK: - Search Response
public struct SearchTracksResponse: Codable {
    public let tracks: SearchTracksResultDTO
}

public struct SearchTracksResultDTO: Codable {
    public let href: String
    public let limit: Int
    public let next: String?
    public let offset: Int
    public let previous: String?
    public let total: Int
    public let items: [TrackDTO]
}

// MARK: - Create/Update Playlist Response
public struct CreatePlaylistResponse: Codable {
    public let collaborative: Bool
    public let description: String?
    public let externalUrls: ExternalUrls
    public let followers: FollowersDTO?
    public let href: String
    public let id: String
    public let images: [SpotifyImage]?
    public let name: String
    public let owner: PlaylistOwnerDTO
    public let `public`: Bool?
    public let snapshotId: String
    public let tracks: PlaylistTracksInfoDTO
    public let type: String
    public let uri: String

    enum CodingKeys: String, CodingKey {
        case collaborative, description, followers, href, id, images, name, owner, type, uri, tracks
        case externalUrls = "external_urls"
        case `public` = "public"
        case snapshotId = "snapshot_id"
    }
}

// MARK: - Followers
public struct FollowersDTO: Codable {
    public let href: String?
    public let total: Int
}

// MARK: - Snapshot Response
public struct SnapshotResponse: Codable {
    public let snapshotId: String

    enum CodingKeys: String, CodingKey {
        case snapshotId = "snapshot_id"
    }
}

// MARK: - User Profile
public struct UserProfileDTO: Codable {
    public let displayName: String?
    public let externalUrls: ExternalUrls
    public let followers: FollowersDTO?
    public let href: String
    public let id: String
    public let images: [SpotifyImage]?
    public let type: String
    public let uri: String

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case externalUrls = "external_urls"
        case followers, href, id, images, type, uri
    }
}
