import Foundation
import ReactorKit
import RxSwift

public final class SplashViewReactor: Reactor {
    public enum Action {
        case viewDidAppear
    }
    public enum Mutation {
        case startTimer
        case timerCompleted
    }
    public struct State {
        public var isLoading: Bool = true
        public var shouldRouteToOnboarding: Bool = false
        public init() {}
    }

    public let initialState: State = State()
    private let timerDuration: RxTimeInterval = .milliseconds(500)

    public init() {}

    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidAppear:
            return .concat([
                .just(.startTimer),
                Observable<Mutation>.just(.timerCompleted)
                    .delay(timerDuration, scheduler: MainScheduler.instance)
            ])
        }
    }

    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .startTimer:
            newState.isLoading = true
        case .timerCompleted:
            newState.isLoading = false
            newState.shouldRouteToOnboarding = true
        }
        return newState
    }
}
