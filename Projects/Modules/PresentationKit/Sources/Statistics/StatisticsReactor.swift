import Foundation
import ReactorKit
import RxSwift
import DomainKit

public final class StatisticsReactor: Reactor {
    // MARK: - Action
    public enum Action {
        case viewDidLoad
        case selectTimeRange(SpotifyTimeRange)
        case refresh
    }

    // MARK: - Mutation
    public enum Mutation {
        case setTimeRange(SpotifyTimeRange)
        case setTopArtists([TopArtist])
        case setLoading(Bool)
        case setError(String?)
    }

    // MARK: - State
    public struct State {
        public var timeRange: SpotifyTimeRange = .mediumTerm
        public var topArtists: [TopArtist] = []
        public var isLoading: Bool = false
        public var errorMessage: String?

        public init() {}
    }

    public let initialState: State = .init()

    private let spotifyStateManager: SpotifyStateManagerProtocol

    // MARK: - Init
    public init(spotifyStateManager: SpotifyStateManagerProtocol) {
        self.spotifyStateManager = spotifyStateManager
    }

    // MARK: - Mutate
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            // 초기 로드: 현재 타임레인지로 Top Artists 갱신
            return .concat([
                .just(.setLoading(true)),
                refreshTopArtists(currentState.timeRange),
                .just(.setLoading(false))
            ])

        case .selectTimeRange(let timeRange):
            return .concat([
                .just(.setTimeRange(timeRange)),
                .just(.setLoading(true)),
                refreshTopArtists(timeRange),
                .just(.setLoading(false))
            ])

        case .refresh:
            return .concat([
                .just(.setLoading(true)),
                refreshTopArtists(currentState.timeRange),
                .just(.setLoading(false))
            ])
        }
    }

    // MARK: - Transform
    public func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let managerMutations = Observable.merge([
            spotifyStateManager.topArtists
                .map { Mutation.setTopArtists($0) },

            spotifyStateManager.isLoading
                .map { Mutation.setLoading($0) },

            spotifyStateManager.error
                .compactMap { $0 }
                .map { Mutation.setError($0) }
        ])

        return Observable.merge(mutation, managerMutations)
    }

    // MARK: - Reduce
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.errorMessage = nil

        switch mutation {
        case .setTimeRange(let range):
            newState.timeRange = range

        case .setTopArtists(let artists):
            // 순위를 부여하여 표시
            let ranked = artists.enumerated().map { index, item in
                TopArtist(artist: item.artist, rank: index + 1)
            }
            newState.topArtists = ranked

        case .setLoading(let isLoading):
            newState.isLoading = isLoading

        case .setError(let message):
            newState.errorMessage = message
        }

        return newState
    }

    // MARK: - Private
    private func refreshTopArtists(_ timeRange: SpotifyTimeRange) -> Observable<Mutation> {
        spotifyStateManager.refreshTopArtists(timeRange: timeRange, limit: 20)
        return .empty()
    }
}
