import Foundation
import ReactorKit
import RxSwift
import FoundationKit

public final class SettingsReactor: Reactor {
    public enum Action {
        case viewDidLoad
        case logout
        case confirmLogout
    }
    
    public enum Mutation {
        case setShowLogoutAlert(Bool)
        case setLogoutCompleted(Bool)
        case setError(String?)
    }
    
    public struct State {
        public var showLogoutAlert: Bool = false
        public var isLogoutCompleted: Bool = false
        public var errorMessage: String?
        
        public init() {}
    }
    
    public let initialState: State = .init()
    
    private let tokenStorage: TokenStorageProtocol

    public init(tokenStorage: TokenStorageProtocol = TokenStorage.shared) {
        self.tokenStorage = tokenStorage
    }

    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .empty()
            
        case .logout:
            return .just(.setShowLogoutAlert(true))
            
        case .confirmLogout:
            return performLogout()
        }
    }

    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setShowLogoutAlert(let show):
            newState.showLogoutAlert = show
            
        case .setLogoutCompleted(let completed):
            newState.isLogoutCompleted = completed
            
        case .setError(let error):
            newState.errorMessage = error
        }
        
        return newState
    }
    
    private func performLogout() -> Observable<Mutation> {
        return Observable.create { observer in
            do {
                try self.tokenStorage.clearTokens()
                observer.onNext(.setLogoutCompleted(true))
                observer.onNext(.setShowLogoutAlert(false))
            } catch {
                observer.onNext(.setError("로그아웃 중 오류가 발생했습니다: \(error.localizedDescription)"))
                observer.onNext(.setShowLogoutAlert(false))
            }
            observer.onCompleted()
            return Disposables.create()
        }
    }
}