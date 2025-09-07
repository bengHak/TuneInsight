import Foundation
import ReactorKit
import RxSwift
import DomainKit

public final class HomeReactor: Reactor {
    
    // MARK: - Action
    
    public enum Action {
        case viewDidLoad
        case refresh
        case refreshPlayback
        case playPause
        case nextTrack
        case previousTrack
        case seek(positionMs: Int)
        case startAutoRefresh
        case stopAutoRefresh
        case startProgressTimer
        case stopProgressTimer
        case updateProgressTick
    }
    
    // MARK: - Mutation
    
    public enum Mutation {
        case setLoading(Bool)
        case setCurrentPlayback(CurrentPlayback?)
        case setRecentTracks([RecentTrack])
        case setError(String?)
        case updatePlaybackState
        case updatePlaybackDisplay
        case setLastPlaybackFetchTime(Date)
    }
    
    // MARK: - State
    
    public struct State {
        public var currentPlayback: CurrentPlayback?
        public var lastPlaybackFetchTime: Date?
        public var recentTracks: [RecentTrack] = []
        public var isLoading: Bool = false
        public var errorMessage: String?
        public var playbackDisplay: PlaybackDisplay?
        
        public init() {}
    }
    
    public struct PlaybackDisplay: Equatable {
        public let track: SpotifyTrack?
        public let isPlaying: Bool
        public let currentProgressMs: Int
        public let durationMs: Int
        public let progressPercentage: Float
        public let formattedProgress: String
        public let formattedDuration: String
        
        public init(track: SpotifyTrack?, isPlaying: Bool, currentProgressMs: Int) {
            self.track = track
            self.isPlaying = isPlaying
            self.currentProgressMs = currentProgressMs
            self.durationMs = track?.durationMs ?? 0
            self.progressPercentage = durationMs > 0 ? Float(currentProgressMs) / Float(durationMs) : 0.0
            
            let seconds = currentProgressMs / 1000
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            self.formattedProgress = String(format: "%d:%02d", minutes, remainingSeconds)
            
            self.formattedDuration = track?.durationFormatted ?? "0:00"
        }
    }
    
    // MARK: - Properties
    
    public let initialState = State()
    
    private let getCurrentPlaybackUseCase: GetCurrentPlaybackUseCaseProtocol
    private let getRecentlyPlayedUseCase: GetRecentlyPlayedUseCaseProtocol
    private let playbackControlUseCase: PlaybackControlUseCaseProtocol
    
    private let autoRefreshScheduler = SerialDispatchQueueScheduler(qos: .background)
    private var autoRefreshDisposable: Disposable?
    private var progressTimerDisposable: Disposable?
    
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
        progressTimerDisposable?.dispose()
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
            
        case .refreshPlayback:
            return loadCurrentPlayback()
            
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
            
        case .startProgressTimer:
            return startProgressTimerMutation()
            
        case .stopProgressTimer:
            progressTimerDisposable?.dispose()
            return .empty()
            
        case .updateProgressTick:
            guard currentState.currentPlayback != nil else {
                return .empty()
            }
            return .just(.updatePlaybackDisplay)
        }
    }
    
    // MARK: - Reduce
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.errorMessage = nil
        
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setCurrentPlayback(let playback):
            newState.currentPlayback = playback
            
            if let playback,
               let track = playback.track {
                newState.playbackDisplay = PlaybackDisplay(
                    track: track,
                    isPlaying: playback.isPlaying,
                    currentProgressMs: playback.progressMs ?? 0
                )
            } else {
                newState.playbackDisplay = nil
            }
            
        case .setRecentTracks(let tracks):
            newState.recentTracks = tracks
            newState.errorMessage = nil
            
        case .setError(let error):
            newState.errorMessage = error
            
        case .updatePlaybackState:
            break
            
        case .updatePlaybackDisplay:
            guard let currentPlayback = state.currentPlayback,
                  let track = currentPlayback.track,
                  currentPlayback.isPlaying else {
                newState.playbackDisplay = state.playbackDisplay
                break
            }
            
            let currentTime = Date().timeIntervalSince1970 * 1000
            let lastFetchTime = state.lastPlaybackFetchTime?.timeIntervalSince1970 ?? (currentTime / 1000)
            let elapsedTime = currentTime - lastFetchTime * 1000
            let originalProgressMs = currentPlayback.progressMs ?? 0
            
            var newProgressMs = originalProgressMs + Int(elapsedTime)
            newProgressMs = min(newProgressMs, track.durationMs)
            
            newState.playbackDisplay = PlaybackDisplay(
                track: track,
                isPlaying: currentPlayback.isPlaying,
                currentProgressMs: newProgressMs
            )
            
        case .setLastPlaybackFetchTime(let date):
            newState.lastPlaybackFetchTime = date
        }
        
        return newState
    }
    
    // MARK: - Private Methods
    
    private func loadCurrentPlayback() -> Observable<Mutation> {
        return Observable.create { [weak self] observer in
            Task {
                guard let self else { return }
                do {
                    let playback = try await self.getCurrentPlaybackUseCase.execute()
                    observer.onNext(.setLastPlaybackFetchTime(Date()))
                    observer.onNext(.setCurrentPlayback(playback))
                    
                    if playback.isPlaying && playback.track != nil {
                        self.action.onNext(.startProgressTimer)
                    } else {
                        self.action.onNext(.stopProgressTimer)
                    }
                } catch SpotifyRepositoryError.noCurrentlyPlaying {
                    observer.onNext(.setCurrentPlayback(nil))
                    self.action.onNext(.stopProgressTimer)
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
                    observer.onNext(.setLastPlaybackFetchTime(Date()))
                    
                    if playback.isPlaying && playback.track != nil {
                        DispatchQueue.main.async {
                            self.action.onNext(.startProgressTimer)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.action.onNext(.stopProgressTimer)
                        }
                    }
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
            .map { _ in Action.refreshPlayback }
            .bind(to: action.asObserver())
        
        return .empty()
    }
    
    private func startProgressTimerMutation() -> Observable<Mutation> {
        progressTimerDisposable?.dispose()
        
        guard let currentPlayback = currentState.currentPlayback,
              currentPlayback.isPlaying,
              currentPlayback.track != nil else {
            return .empty()
        }
        
        progressTimerDisposable = Observable<Int>
            .interval(.seconds(1), scheduler: MainScheduler.instance)
            .map { _ in Action.updateProgressTick }
            .bind(to: action.asObserver())
        
        return .empty()
    }
}
