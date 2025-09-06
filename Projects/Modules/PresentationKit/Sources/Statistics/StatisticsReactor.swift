import Foundation
import ReactorKit
import RxSwift

public final class StatisticsReactor: Reactor {
    public enum Action {
        case viewDidLoad
    }
    
    public enum Mutation {
    }
    
    public struct State {
        public init() {}
    }
    
    public let initialState: State = .init()

    public init() {}

    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .empty()
        }
    }

    public func reduce(state: State, mutation: Mutation) -> State {
        return state
    }
}