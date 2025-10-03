import Foundation
import Alamofire
import FoundationKit

public protocol SpotifyAuthAPIProtocol: Sendable {
    func refreshAccessToken() async throws -> SpotifyToken
}

struct SpotifyRefreshTokenResponse: Decodable {
    let access_token: String
    let token_type: String?
    let scope: String?
    let expires_in: Int
    let refresh_token: String?
}

public final class SpotifyAuthAPI: SpotifyAuthAPIProtocol, @unchecked Sendable {
    private let accountsBaseURL = "https://accounts.spotify.com"
    private let tokenPath = "/api/token"
    private let session: Session
    private let tokenStorage: TokenStorageProtocol
    
    public init(session: Session = .default, tokenStorage: TokenStorageProtocol = TokenStorage.shared) {
        self.session = session
        self.tokenStorage = tokenStorage
    }
    
    public func refreshAccessToken() async throws -> SpotifyToken {
        // 기존 리프레시 토큰 확보
        let current = try tokenStorage.loadToken()
        let refreshToken = current.refreshToken
        let clientID = AppConstants.spotifyClientID
        guard !clientID.isEmpty else {
            throw NSError(domain: "SpotifyAuthAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "SPOTIFY_CLIENT_ID 미설정".localized()])
        }

        let url = URL(string: accountsBaseURL + tokenPath)!
        let params: [String: String] = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": clientID
        ]
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]

        return try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: .post, parameters: params, encoding: URLEncoding.httpBody, headers: headers)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: SpotifyRefreshTokenResponse.self) { response in
                    switch response.result {
                    case .success(let payload):
                        let newAccess = payload.access_token
                        let newRefresh = payload.refresh_token ?? refreshToken
                        let expires = payload.expires_in
                        let expiration = Date().addingTimeInterval(TimeInterval(expires))
                        let newToken = SpotifyToken(accessToken: newAccess, refreshToken: newRefresh, expirationDate: expiration)
                        continuation.resume(returning: newToken)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}
