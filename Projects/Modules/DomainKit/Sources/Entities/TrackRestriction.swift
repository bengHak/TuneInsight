import Foundation

public struct TrackRestriction: Sendable, Equatable {
    public let reason: String

    public init(reason: String) {
        self.reason = reason
    }
}
