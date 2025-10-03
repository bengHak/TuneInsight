import Foundation
import UIKit
import SpotifyiOS
import FoundationKit
import RxSwift

public enum SpotifyAuthState {
    case idle
    case authorizing
    case authorized(session: SPTSession)
    case failed(error: Error)
}

public final class SpotifyAuthManager: NSObject, ObservableObject {
    public static let shared = SpotifyAuthManager()
    
    private let clientID: String = AppConstants.spotifyClientID
    private let redirectURI: URL = URL(string: "sparkspotifystats://callback")!

    private lazy var configuration: SPTConfiguration = {
        let config = SPTConfiguration(clientID: clientID, redirectURL: redirectURI)
        config.playURI = nil
        return config
    }()

    private lazy var sessionManager: SPTSessionManager = {
        SPTSessionManager(configuration: configuration, delegate: self)
    }()

    private let stateSubject = BehaviorSubject<SpotifyAuthState>(value: .idle)
    public var authorizationState: Observable<SpotifyAuthState> { stateSubject.asObservable() }
    
    private var currentSession: SPTSession?
    private let tokenStorage: TokenStorageProtocol
    
    public var isAuthorized: Bool {
        return tokenStorage.hasValidToken() || (currentSession != nil && !currentSession!.isExpired)
    }

    private init(tokenStorage: TokenStorageProtocol = TokenStorage.shared) { 
        self.tokenStorage = tokenStorage
        super.init()
        loadStoredSession()
    }

    public func startAuthorization(from viewController: UIViewController) {
        guard !clientID.isEmpty else {
            stateSubject.onNext(.failed(error: NSError(domain: "SpotifyAuthManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Client ID is not configured."])))
            return
        }
        let scopes: SPTScope = [
            .playlistReadPrivate,
            .playlistReadCollaborative,
            .playlistModifyPublic,
            .playlistModifyPrivate,
            .userFollowRead,
            .userFollowModify,
            .userLibraryRead,
            .userLibraryModify,
            .userReadEmail,
            .userReadPrivate,
            .userTopRead,
            .ugcImageUpload,
            .appRemoteControl,            // iOS/Android SDK용 리모트 제어
            .userReadPlaybackState,
            .userModifyPlaybackState,
            .userReadCurrentlyPlaying,
            .userReadRecentlyPlayed,
            .streaming
            // 제거: .userReadBirthDate (폐지), .openid (미지원)
            // 선택: .streaming (Web Playback SDK 쓸 때만)
        ]

        stateSubject.onNext(.authorizing)
        sessionManager.initiateSession(with: scopes, campaign: nil)
    }

    public func handle(url: URL) {
        sessionManager.application(UIApplication.shared, open: url, options: [:])
    }

    private func loadStoredSession() {
        // 키체인에서 토큰 확인
        if tokenStorage.hasValidToken() {
            // UserDefaults에서 SPTSession 정보도 확인 (기존 호환성 유지)
            if let session = UserDefaultsManager.shared.getSecurely(SPTSession.self, for: .spotifySession) {
                currentSession = session
                if !session.isExpired {
                    stateSubject.onNext(.authorized(session: session))
                    return
                }
            }
            
            // 키체인에는 토큰이 있지만 SPTSession이 없거나 만료된 경우
            // 토큰을 다시 인증해야 함
            do {
                let token = try tokenStorage.loadToken()
                if token.isValid {
                    // 유효한 토큰이 있으므로 인증된 상태로 간주하지만 실제 SPTSession은 없음
                    // 실제 사용 시에는 토큰을 직접 사용하거나 세션을 새로 만들어야 함
                    print("[SpotifyAuthManager] " + "auth.keychainTokenWithoutSession".localized())
                    stateSubject.onNext(.idle) // 재인증 필요
                } else {
                    try tokenStorage.deleteToken() // 만료된 토큰 삭제
                }
            } catch {
                print("[SpotifyAuthManager] " + "auth.keychainTokenLoadFailure".localizedFormat(String(describing: error)))
            }
        }
    }
    

    
    private func storeSession(_ session: SPTSession) {
        currentSession = session
        
        // 기존 UserDefaults 저장 유지 (호환성)
        UserDefaultsManager.shared.saveSecurely(session, for: .spotifySession)
        
        // 키체인에도 토큰 저장
        let spotifyToken = SpotifyToken(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
            expirationDate: session.expirationDate
        )
        
        do {
            try tokenStorage.saveToken(spotifyToken)
            print("[SpotifyAuthManager] " + "auth.keychainTokenSaved".localized())
        } catch {
            print("[SpotifyAuthManager] " + "auth.keychainTokenSaveFailure".localizedFormat(String(describing: error)))
        }
    }
    
    public func getCurrentSession() -> SPTSession? {
        return currentSession
    }
    
    // MARK: - 키체인 기반 토큰 관리
    
    public func getCurrentAccessToken() -> String? {
        do {
            return try tokenStorage.getCurrentAccessToken()
        } catch {
            print("[SpotifyAuthManager] " + "auth.accessTokenFetchFailure".localizedFormat(String(describing: error)))
            return nil
        }
    }
    
    public func getCurrentRefreshToken() -> String? {
        do {
            return try tokenStorage.getCurrentRefreshToken()
        } catch {
            print("[SpotifyAuthManager] " + "auth.refreshTokenFetchFailure".localizedFormat(String(describing: error)))
            return nil
        }
    }
    
    public func signOut() {
        do {
            try tokenStorage.deleteToken()
            currentSession = nil
            stateSubject.onNext(.idle)
            print("[SpotifyAuthManager] " + "auth.logoutKeychainCleared".localized())
        } catch {
            print("[SpotifyAuthManager] " + "auth.logoutKeychainError".localizedFormat(String(describing: error)))
        }
        
        // UserDefaults도 정리
        UserDefaultsManager.shared.remove(for: .spotifySession)
    }
}

extension SpotifyAuthManager: SPTSessionManagerDelegate {
    public func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        stateSubject.onNext(.failed(error: error))
    }
    public func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        storeSession(session)
        stateSubject.onNext(.authorized(session: session))
    }
    public func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        storeSession(session)
        stateSubject.onNext(.authorized(session: session))
    }
}
