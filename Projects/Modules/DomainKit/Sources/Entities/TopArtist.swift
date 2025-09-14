import Foundation

public enum TopArtistTimeRange: String, CaseIterable, Sendable {
    case shortTerm = "short_term"
    case mediumTerm = "medium_term"
    case longTerm = "long_term"

    public var displayName: String {
        switch self {
        case .shortTerm:
            return "최근 4주"
        case .mediumTerm:
            return "최근 6개월"
        case .longTerm:
            return "최근 1년"
        }
    }
}

public struct TopArtist: Sendable, Equatable {
    public let artist: SpotifyArtist
    public let rank: Int?

    public init(
        artist: SpotifyArtist,
        rank: Int? = nil
    ) {
        self.artist = artist
        self.rank = rank
    }
}

public extension TopArtist {
    var id: String { artist.id }
    var name: String { artist.name }
    var uri: String { artist.uri }
    var images: [SpotifyImage] { artist.images }
    var genres: [String] { artist.genres }
    var popularity: Int? { artist.popularity }

    var displayName: String {
        if let rank = rank {
            return "\(rank). \(name)"
        }
        return name
    }
}