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

    private override init() { super.init() }

    public func startAuthorization(from viewController: UIViewController) {
        guard !clientID.isEmpty else {
            stateSubject.onNext(.failed(error: NSError(domain: "SpotifyAuthManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Client ID is not configured."])))
            return
        }
        let scope: SPTScope = [.userReadPrivate, .userTopRead]
        stateSubject.onNext(.authorizing)
        sessionManager.initiateSession(with: scope, campaign: nil)
    }

    public func handle(url: URL) {
        sessionManager.application(UIApplication.shared, open: url, options: [:])
    }
}

extension SpotifyAuthManager: SPTSessionManagerDelegate {
    public func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        stateSubject.onNext(.failed(error: error))
    }
    public func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        stateSubject.onNext(.authorized(session: session))
    }
    public func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        stateSubject.onNext(.authorized(session: session))
    }
}
