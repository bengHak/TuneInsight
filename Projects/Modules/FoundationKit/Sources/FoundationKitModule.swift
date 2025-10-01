import Foundation

// FoundationKit 모듈의 기본 소스 파일
// 공통 유틸리티 및 기초 기능들이 여기에 위치합니다.
public final class FoundationKitModule {
    public static let shared = FoundationKitModule()
    
    private init() {}
    
    public func configure() {
        // Foundation 관련 설정을 위한 기본 코드
    }
}

// MARK: - AppConstants
public enum AppConstants {
    private static let searchBundles: [Bundle] = {
        var bundles: [Bundle] = [Bundle.main]
        if let foundationBundle = Bundle(identifier: Bundle.main.bundleIdentifier ?? "") { // fallback logic
            if !bundles.contains(foundationBundle) { bundles.append(foundationBundle) }
        }
        return bundles
    }()

    private static func infoValue(_ key: String) -> String? {
        for bundle in searchBundles {
            if let value = bundle.object(forInfoDictionaryKey: key) as? String, !value.isEmpty { return value }
        }
        return nil
    }

    public enum Keys: String {
        case spotifyClientID = "SPOTIFY_CLIENT_ID"
        case spotifyAPIBaseURL = "SPOTIFY_API_BASE_URL"
    }

    public static var spotifyClientID: String {
        guard let value = infoValue(Keys.spotifyClientID.rawValue) else {
            assertionFailure("Missing Info.plist key: \(Keys.spotifyClientID.rawValue)")
            return ""
        }
        return value
    }

    public static var spotifyAPIBaseURL: String {
        guard let value = infoValue(Keys.spotifyAPIBaseURL.rawValue) else {
            assertionFailure("Missing Info.plist key: \(Keys.spotifyAPIBaseURL.rawValue)")
            return ""
        }
        return value
    }
}
