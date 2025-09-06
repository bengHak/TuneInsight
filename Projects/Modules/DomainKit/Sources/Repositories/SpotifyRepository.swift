import Foundation

public enum SpotifyRepositoryError: Error {
    case noCurrentlyPlaying
    case unauthorized
    case networkError(Error)
    case unknown(Error)
    
    public var localizedDescription: String {
        switch self {
        case .noCurrentlyPlaying:
            return "현재 재생 중인 곡이 없습니다."
        case .unauthorized:
            return "Spotify 인증이 필요합니다."
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .unknown(let error):
            return "알 수 없는 오류: \(error.localizedDescription)"
        }
    }
}

public protocol SpotifyRepository {
    func getCurrentPlayback() async throws -> CurrentPlayback
    func getRecentlyPlayed(limit: Int) async throws -> [RecentTrack]
    func play() async throws
    func pause() async throws
    func nextTrack() async throws
    func previousTrack() async throws
    func seek(to positionMs: Int) async throws
}