import Foundation
import ReactorKit
import RxSwift
import FoundationKit

public final class OnboardingReactor: Reactor {
    public enum Action {
        case viewDidLoad
        case nextButtonTapped
        case checkAuthentication
    }
    
    public enum Mutation {
        case showMainTab
        case showSignIn
    }
    
    public struct State {
        public var shouldShowSignIn = false
        public init() {}
    }
    
    public let initialState: State = .init()
    
    public weak var coordinator: OnboardingCoordinator?
    private let tokenStorage: TokenStorageProtocol

    public init(coordinator: OnboardingCoordinator? = nil, tokenStorage: TokenStorageProtocol = TokenStorage.shared) {
        self.coordinator = coordinator
        self.tokenStorage = tokenStorage
    }

    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .empty()
        case .nextButtonTapped:
            coordinator?.showMainTab()
            return .empty()
        case .checkAuthentication:
            return checkAuthenticationStatus()
        }
    }

    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .showMainTab:
            break
        case .showSignIn:
            newState.shouldShowSignIn = true
        }
        return newState
    }
    
    private func checkAuthenticationStatus() -> Observable<Mutation> {
        return Observable.create { [weak self] observer in
            defer { observer.onCompleted() }
            guard let self else {
                return Disposables.create()
            }
            
            let hasValidToken = self.tokenStorage.hasValidToken()
            if !hasValidToken {
                observer.onNext(.showSignIn)
            }
            
            return Disposables.create()
        }
    }
}
