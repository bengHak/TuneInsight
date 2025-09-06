import Foundation

public struct SpotifyImage: Sendable, Equatable {
    public let url: String
    public let height: Int?
    public let width: Int?
    
    public init(url: String, height: Int? = nil, width: Int? = nil) {
        self.url = url
        self.height = height
        self.width = width
    }
}