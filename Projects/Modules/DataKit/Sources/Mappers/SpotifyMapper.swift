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
