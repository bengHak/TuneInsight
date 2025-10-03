import Foundation
import ReactorKit
import RxSwift
import DomainKit

public final class TrackDetailReactor: Reactor {
    // MARK: - Action
    public enum Action {
        case viewDidLoad
        case refresh
        case addToQueue
        case skipToNext
        case playNow // 대기열 추가 후 즉시 재생
        case playPause
        case seek(positionMs: Int)
    }

    // MARK: - Mutation
    public enum Mutation {
        case setError(String?)
        case setIsProcessing(Bool)
        case setIsRefreshing(Bool)
    }

    // MARK: - State
    public struct State {
        public let track: SpotifyTrack
        public var isProcessing: Bool = false
        public var isRefreshing: Bool = false
        public var errorMessage: String?

        public init(track: SpotifyTrack) {
            self.track = track
        }
    }

    // MARK: - Properties
    public let initialState: State
    private let playbackControlUseCase: PlaybackControlUseCaseProtocol
    private let spotifyStateManager: SpotifyStateManagerProtocol

    // 외부에서 PlayerView 상태 업데이트를 구독할 수 있도록 노출
    public var playbackDisplay: Observable<PlaybackDisplay?> { spotifyStateManager.playbackDisplay }

    // MARK: - Init
    public init(
        track: SpotifyTrack,
        playbackControlUseCase: PlaybackControlUseCaseProtocol,
        spotifyStateManager: SpotifyStateManagerProtocol
    ) {
        self.initialState = State(track: track)
        self.playbackControlUseCase = playbackControlUseCase
        self.spotifyStateManager = spotifyStateManager
    }

    // MARK: - Mutate
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .empty()

        case .refresh:
            return Observable.concat([
                .just(.setIsRefreshing(true)),
                refreshPlaybackState()
                    .andThen(Observable<Mutation>.just(.setIsRefreshing(false)))
                    .catch { .just(.setError($0.localizedDescription)) }
            ])

        case .addToQueue:
            return Observable.concat([
                .just(.setIsProcessing(true)),
                addToQueue(trackURI: currentState.track.uri)
                    .andThen(Observable<Mutation>.just(.setIsProcessing(false)))
                    .catch { .just(.setError($0.localizedDescription)) }
            ])

        case .skipToNext:
            return Observable.concat([
                .just(.setIsProcessing(true)),
                skipToNext()
                    .andThen(Observable<Mutation>.just(.setIsProcessing(false)))
                    .catch { .just(.setError($0.localizedDescription)) }
            ])

        case .playPause:
            spotifyStateManager.playPause()
            return .empty()

        case .seek(let positionMs):
            spotifyStateManager.seek(to: positionMs)
            return .empty()

        case .playNow:
            return Observable.concat([
                .just(.setIsProcessing(true)),
                addToQueue(trackURI: currentState.track.uri)
                    .andThen(skipToNext())
                    .andThen(Observable<Mutation>.just(.setIsProcessing(false)))
                    .catch { error in
                        Observable.from([
                            .setIsProcessing(false),
                            .setError(error.localizedDescription)
                        ])
                    }
            ])
        }
    }

    // MARK: - Reduce
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setError(let message):
            newState.errorMessage = message
        case .setIsProcessing(let processing):
            newState.isProcessing = processing
        case .setIsRefreshing(let refreshing):
            newState.isRefreshing = refreshing
        }
        return newState
    }
}

// MARK: - Side Effects
private extension TrackDetailReactor {
    func refreshPlaybackState() -> Completable {
        return Completable.create { [weak self] observer in
            guard let self else { observer(.completed); return Disposables.create() }

            // 재생 상태를 새로고침
            self.spotifyStateManager.refreshPlayback()

            // 약간의 지연을 두어 사용자에게 새로고침 피드백 제공
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                observer(.completed)
            }

            return Disposables.create()
        }
    }
    func addToQueue(trackURI: String) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self else { observer(.completed); return Disposables.create() }
            Task {
                do {
                    try await self.playbackControlUseCase.addToQueue(uri: trackURI)
                    observer(.completed)
                } catch {
                    observer(.error(error))
                }
            }
            return Disposables.create()
        }
    }

    func skipToNext() -> Completable {
        return Completable.create { [weak self] observer in
            guard let self else { observer(.completed); return Disposables.create() }
            Task {
                do {
                    try await self.playbackControlUseCase.nextTrack()
                    // 최신 재생 상태 갱신
                    self.spotifyStateManager.refreshPlayback()
                    observer(.completed)
                } catch {
                    observer(.error(error))
                }
            }
            return Disposables.create()
        }
    }
}
