import Foundation
import ReactorKit
import RxSwift
import DomainKit

public final class HomeReactor: Reactor {
    
    // MARK: - Action
    
    public enum Action {
        case viewDidLoad
        case refresh
        case playPause
        case nextTrack
        case previousTrack
        case seek(positionMs: Int)
        case startAutoRefresh
        case stopAutoRefresh
    }
    
    // MARK: - Mutation
    
    public enum Mutation {
        case setLoading(Bool)
        case setCurrentPlayback(CurrentPlayback?)
        case setRecentTracks([RecentTrack])
        case setError(String?)
        case updatePlaybackState
    }
    
    // MARK: - State
    
    public struct State {
        public var currentPlayback: CurrentPlayback?
        public var recentTracks: [RecentTrack] = []
        public var isLoading: Bool = false
        public var errorMessage: String?
        
        public init() {}
    }
    
    // MARK: - Properties
    
    public let initialState = State()
    
    private let getCurrentPlaybackUseCase: GetCurrentPlaybackUseCaseProtocol
    private let getRecentlyPlayedUseCase: GetRecentlyPlayedUseCaseProtocol
    private let playbackControlUseCase: PlaybackControlUseCaseProtocol
    
    private let autoRefreshScheduler = SerialDispatchQueueScheduler(qos: .background)
    private var autoRefreshDisposable: Disposable?
    
    // MARK: - Initializer
    
    public init(
        getCurrentPlaybackUseCase: GetCurrentPlaybackUseCaseProtocol,
        getRecentlyPlayedUseCase: GetRecentlyPlayedUseCaseProtocol,
        playbackControlUseCase: PlaybackControlUseCaseProtocol
    ) {
        self.getCurrentPlaybackUseCase = getCurrentPlaybackUseCase
        self.getRecentlyPlayedUseCase = getRecentlyPlayedUseCase
        self.playbackControlUseCase = playbackControlUseCase
    }
    
    deinit {
        autoRefreshDisposable?.dispose()
    }
    
    // MARK: - Mutate
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .concat([
                .just(.setLoading(true)),
                loadCurrentPlayback(),
                loadRecentTracks(),
                .just(.setLoading(false)),
                startAutoRefreshMutation()
            ])
            
        case .refresh:
            return .concat([
                .just(.setLoading(true)),
                loadCurrentPlayback(),
                loadRecentTracks(),
                .just(.setLoading(false))
            ])
            
        case .playPause:
            return performPlayPauseAction()
            
        case .nextTrack:
            return performPlaybackControlAction {
                try await self.playbackControlUseCase.nextTrack()
            }
            
        case .previousTrack:
            return performPlaybackControlAction {
                try await self.playbackControlUseCase.previousTrack()
            }
            
        case .seek(let positionMs):
            return performPlaybackControlAction {
                try await self.playbackControlUseCase.seek(to: positionMs)
            }
            
        case .startAutoRefresh:
            return startAutoRefreshMutation()
            
        case .stopAutoRefresh:
            autoRefreshDisposable?.dispose()
            return .empty()
        }
    }
    
    // MARK: - Reduce
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setCurrentPlayback(let playback):
            newState.currentPlayback = playback
            newState.errorMessage = nil
            
        case .setRecentTracks(let tracks):
            newState.recentTracks = tracks
            newState.errorMessage = nil
            
        case .setError(let error):
            newState.errorMessage = error
            
        case .updatePlaybackState:
            break
        }
        
        return newState
    }
    
    // MARK: - Private Methods
    
    private func loadCurrentPlayback() -> Observable<Mutation> {
        return Observable.create { observer in
            Task {
                do {
                    let playback = try await self.getCurrentPlaybackUseCase.execute()
                    observer.onNext(.setCurrentPlayback(playback))
                } catch SpotifyRepositoryError.noCurrentlyPlaying {
                    observer.onNext(.setCurrentPlayback(nil))
                } catch SpotifyRepositoryError.unauthorized {
                    observer.onNext(.setError("Spotify 인증이 만료되었습니다. 다시 로그인해주세요."))
                } catch {
                    observer.onNext(.setError(error.localizedDescription))
                }
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    private func loadRecentTracks() -> Observable<Mutation> {
        return Observable.create { observer in
            Task {
                do {
                    let tracks = try await self.getRecentlyPlayedUseCase.execute(limit: 5)
                    observer.onNext(.setRecentTracks(tracks))
                } catch SpotifyRepositoryError.unauthorized {
                    observer.onNext(.setError("Spotify 인증이 만료되었습니다. 다시 로그인해주세요."))
                } catch {
                    observer.onNext(.setError(error.localizedDescription))
                }
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    private func performPlayPauseAction() -> Observable<Mutation> {
        guard let currentPlayback = currentState.currentPlayback else {
            return .just(.setError("재생 중인 곡이 없습니다."))
        }
        
        let action: () async throws -> Void = {
            if currentPlayback.isPlaying {
                try await self.playbackControlUseCase.pause()
            } else {
                try await self.playbackControlUseCase.play()
            }
        }
        
        return performPlaybackControlAction(action: action)
    }
    
    private func performPlaybackControlAction(action: @escaping () async throws -> Void) -> Observable<Mutation> {
        return Observable.create { observer in
            Task {
                do {
                    try await action()
                    
                    // 0.5초 후 재생 상태 업데이트
                    try await Task.sleep(nanoseconds: 500_000_000)
                    
                    let playback = try await self.getCurrentPlaybackUseCase.execute()
                    observer.onNext(.setCurrentPlayback(playback))
                } catch SpotifyRepositoryError.unauthorized {
                    observer.onNext(.setError("Spotify 인증이 만료되었습니다. 다시 로그인해주세요."))
                } catch {
                    observer.onNext(.setError(error.localizedDescription))
                }
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    private func startAutoRefreshMutation() -> Observable<Mutation> {
        autoRefreshDisposable?.dispose()
        
        autoRefreshDisposable = Observable<Int>
            .interval(.seconds(10), scheduler: autoRefreshScheduler)
            .flatMap { _ in self.loadCurrentPlayback() }
            .subscribe()
        
        return .empty()
    }
}

// MARK: - Computed Properties

public extension HomeReactor.State {
    var hasCurrentPlayback: Bool {
        return currentPlayback?.isActive == true
    }
    
    var playButtonTitle: String {
        return currentPlayback?.isPlaying == true ? "일시정지" : "재생"
    }
    
    var playButtonImageName: String {
        return currentPlayback?.isPlaying == true ? "pause.fill" : "play.fill"
    }
}
