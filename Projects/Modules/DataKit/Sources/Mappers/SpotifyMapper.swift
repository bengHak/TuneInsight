import Foundation
import DomainKit

// MARK: - Data to Domain Mapping

public enum SpotifyMapper {
    
    public static func toDomain(_ response: CurrentlyPlayingResponse) -> CurrentPlayback {
        return CurrentPlayback(
            track: response.item?.toDomain(),
            isPlaying: response.isPlaying,
            progressMs: response.progressMs,
            device: response.device?.toDomain(),
            shuffleState: response.shuffleState ?? false,
            repeatState: RepeatState(rawValue: response.repeatState ?? "off") ?? .off,
            timestamp: response.timestamp
        )
    }
    
    public static func toDomain(_ response: RecentlyPlayedResponse) -> [RecentTrack] {
        return response.items.compactMap { playHistory in
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            guard let playedAt = formatter.date(from: playHistory.playedAt) else {
                return nil
            }

            return RecentTrack(
                track: playHistory.track.toDomain(),
                playedAt: playedAt,
                context: playHistory.context?.toDomain()
            )
        }
    }

    public static func toDomain(_ response: TopArtistsResponse) -> [TopArtist] {
        return response.items.enumerated().map { index, artist in
            return TopArtist(
                artist: artist.toDomain(),
                rank: response.offset + index + 1
            )
        }
    }

    public static func toDomain(_ response: TopTracksResponse) -> [TopTrack] {
        return response.items.enumerated().map { index, track in
            return TopTrack(
                track: track.toDomain(),
                rank: response.offset + index + 1
            )
        }
    }

    // MARK: - Artist Detail mappings
    public static func toDomainArtist(_ artist: Artist) -> SpotifyArtist {
        return artist.toDomain()
    }

    public static func toDomain(_ response: ArtistsResponse) -> [SpotifyArtist] {
        return response.artists.map { $0.toDomain() }
    }

    public static func toDomain(_ response: ArtistAlbumsResponse) -> [SpotifyAlbum] {
        return response.items.map { $0.toDomain() }
    }

    public static func toDomain(_ response: ArtistTopTracksResponse) -> [SpotifyTrack] {
        return response.tracks.map { $0.toDomain() }
    }

    public static func toDomain(_ response: AlbumTracksResponse) -> SpotifyAlbumTracksPage {
        let items = response.items.map { $0.toDomain() }
        return SpotifyAlbumTracksPage(
            items: items,
            limit: response.limit ?? items.count,
            offset: response.offset ?? 0,
            total: response.total ?? items.count,
            next: response.next,
            previous: response.previous
        )
    }
}

// MARK: - Track Extensions

private extension Track {
    func toDomain() -> SpotifyTrack {
        return SpotifyTrack(
            id: id,
            name: name,
            artists: artists.map { $0.toDomain() },
            album: album.toDomain(),
            durationMs: durationMs,
            popularity: popularity,
            previewUrl: previewUrl,
            uri: uri
        )
    }
}

private extension SimplifiedTrack {
    func toDomain() -> SpotifyAlbumTrack {
        return SpotifyAlbumTrack(
            id: id,
            name: name,
            discNumber: discNumber,
            trackNumber: trackNumber,
            durationMs: durationMs,
            explicit: explicit,
            uri: uri,
            previewUrl: previewUrl,
            isPlayable: isPlayable,
            isLocal: isLocal,
            artists: artists.map { $0.toDomain() },
            availableMarkets: availableMarkets ?? [],
            restrictions: restrictions?.toDomain()
        )
    }
}

// MARK: - Artist Extensions

private extension Artist {
    func toDomain() -> SpotifyArtist {
        return SpotifyArtist(
            id: id,
            name: name,
            uri: uri,
            images: images?.map { $0.toDomain() } ?? [],
            genres: genres ?? [],
            popularity: popularity
        )
    }
}

// MARK: - Album Extensions

private extension Album {
    func toDomain() -> SpotifyAlbum {
        return SpotifyAlbum(
            id: id,
            name: name,
            images: images.map { $0.toDomain() },
            releaseDate: releaseDate,
            totalTracks: totalTracks,
            artists: artists.map { $0.toDomain() },
            uri: uri
        )
    }
}

// MARK: - Image Extensions

private extension SpotifyImage {
    func toDomain() -> DomainKit.SpotifyImage {
        return DomainKit.SpotifyImage(
            url: url,
            height: height,
            width: width
        )
    }
}

// MARK: - Device Extensions

private extension Device {
    func toDomain() -> PlaybackDevice {
        return PlaybackDevice(
            id: id,
            name: name,
            type: type,
            isActive: isActive,
            volumePercent: volumePercent
        )
    }
}

// MARK: - Context Extensions

private extension PlaybackContext {
    func toDomain() -> DomainKit.PlaybackContext {
        return DomainKit.PlaybackContext(
            type: type,
            uri: uri
        )
    }
}

private extension TrackRestriction {
    func toDomain() -> DomainKit.TrackRestriction {
        return DomainKit.TrackRestriction(reason: reason)
    }
}
