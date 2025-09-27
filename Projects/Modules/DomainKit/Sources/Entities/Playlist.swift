import Foundation

public struct Playlist: Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let description: String?
    public let imageUrl: String?
    public let owner: PlaylistOwner
    public let isPublic: Bool
    public let isCollaborative: Bool
    public let trackCount: Int
    public let snapshotId: String
    public let uri: String

    public init(
        id: String,
        name: String,
        description: String? = nil,
        imageUrl: String? = nil,
        owner: PlaylistOwner,
        isPublic: Bool,
        isCollaborative: Bool,
        trackCount: Int,
        snapshotId: String,
        uri: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.imageUrl = imageUrl
        self.owner = owner
        self.isPublic = isPublic
        self.isCollaborative = isCollaborative
        self.trackCount = trackCount
        self.snapshotId = snapshotId
        self.uri = uri
    }
}

public struct PlaylistOwner: Sendable, Equatable {
    public let id: String
    public let displayName: String
    public let uri: String

    public init(
        id: String,
        displayName: String,
        uri: String
    ) {
        self.id = id
        self.displayName = displayName
        self.uri = uri
    }
}

public struct PlaylistsPage: Sendable {
    public let items: [Playlist]
    public let total: Int
    public let limit: Int
    public let offset: Int
    public let hasNext: Bool
    public let hasPrevious: Bool

    public init(
        items: [Playlist],
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