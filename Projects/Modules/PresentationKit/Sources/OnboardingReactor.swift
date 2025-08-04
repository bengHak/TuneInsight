import Foundation
import ReactorKit
import RxSwift

public final class OnboardingReactor: Reactor {
    public enum Action {
        case viewDidLoad
    }
    public enum Mutation { }
    public struct State {
        public init() {}
    }
    public let initialState: State = .init()

    public init() {}

    public func mutate(action: Action) -> Observable<Mutation> {
        return .empty()
    }

    public func reduce(state: State, mutation: Mutation) -> State {
        return state
    }
}