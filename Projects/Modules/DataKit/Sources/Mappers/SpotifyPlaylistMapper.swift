import Foundation
import DomainKit

public enum SpotifyPlaylistMapper {

    // MARK: - Playlist Mappers

    public static func toDomain(_ dto: PlaylistsResponse) -> PlaylistsPage {
        return PlaylistsPage(
            items: dto.items.map { toDomain($0) },
            total: dto.total,
            limit: dto.limit,
            offset: dto.offset,
            hasNext: dto.next != nil,
            hasPrevious: dto.previous != nil
        )
    }

    public static func toDomain(_ dto: PlaylistDTO) -> Playlist {
        return Playlist(
            id: dto.id,
            name: dto.name,
            description: dto.description,
            imageUrl: dto.images?.first?.url,
            owner: PlaylistOwner(
                id: dto.owner.id,
                displayName: dto.owner.displayName ?? dto.owner.id,
                uri: dto.owner.uri
            ),
            isPublic: dto.public ?? false,
            isCollaborative: dto.collaborative,
            trackCount: dto.tracks.total,
            snapshotId: dto.snapshotId,
            uri: dto.uri
        )
    }

    public static func toDomain(_ dto: CreatePlaylistResponse) -> Playlist {
        return Playlist(
            id: dto.id,
            name: dto.name,
            description: dto.description,
            imageUrl: dto.images?.first?.url,
            owner: PlaylistOwner(
                id: dto.owner.id,
                displayName: dto.owner.displayName ?? dto.owner.id,
                uri: dto.owner.uri
            ),
            isPublic: dto.public ?? false,
            isCollaborative: dto.collaborative,
            trackCount: dto.tracks.total,
            snapshotId: dto.snapshotId,
            uri: dto.uri
        )
    }

    // MARK: - Track Mappers

    public static func toDomain(_ dto: PlaylistTracksResponse) -> PlaylistTracksPage {
        return PlaylistTracksPage(
            items: dto.items.map { toDomain($0) },
            total: dto.total,
            limit: dto.limit,
            offset: dto.offset,
            hasNext: dto.next != nil,
            hasPrevious: dto.previous != nil
        )
    }

    public static func toDomain(_ dto: PlaylistTrackDTO) -> PlaylistTrack {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        return PlaylistTrack(
            id: dto.track.id,
            name: dto.track.name,
            artists: dto.track.artists.map { $0.name },
            album: dto.track.album?.name ?? "",
            albumImageUrl: dto.track.album?.images.first?.url,
            durationMs: dto.track.durationMs,
            uri: dto.track.uri,
            addedAt: dto.addedAt.flatMap { dateFormatter.date(from: $0) },
            addedBy: dto.addedBy?.displayName ?? dto.addedBy?.id,
            previewUrl: dto.track.previewUrl,
            popularity: dto.track.popularity,
            explicit: dto.track.explicit
        )
    }

    // MARK: - Search Mappers

    public static func toDomain(_ dto: SearchTracksResponse) -> SearchTracksPage {
        return SearchTracksPage(
            items: dto.tracks.items.map { toDomain($0) },
            total: dto.tracks.total,
            limit: dto.tracks.limit,
            offset: dto.tracks.offset,
            hasNext: dto.tracks.next != nil,
            hasPrevious: dto.tracks.previous != nil
        )
    }

    public static func toDomain(_ dto: TrackDTO) -> SearchTrackResult {
        return SearchTrackResult(
            id: dto.id,
            name: dto.name,
            artists: dto.artists.map { $0.name },
            album: dto.album?.name ?? "",
            albumImageUrl: dto.album?.images.first?.url,
            durationMs: dto.durationMs,
            uri: dto.uri,
            popularity: dto.popularity,
            explicit: dto.explicit,
            previewUrl: dto.previewUrl
        )
    }
}