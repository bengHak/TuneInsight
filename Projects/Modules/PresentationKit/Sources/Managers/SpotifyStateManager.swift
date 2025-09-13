import Foundation
import ReactorKit
import RxSwift
import RxRelay
import DomainKit

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

public protocol SpotifyStateManagerProtocol {
    var currentPlayback: Observable<CurrentPlayback?> { get }
    var recentTracks: Observable<[RecentTrack]> { get }
    var playbackDisplay: Observable<PlaybackDisplay?> { get }
    var error: Observable<String?> { get }
    var isLoading: Observable<Bool> { get }
    
    func configure(
        getCurrentPlaybackUseCase: GetCurrentPlaybackUseCaseProtocol,
        getRecentlyPlayedUseCase: GetRecentlyPlayedUseCaseProtocol,
        playbackControlUseCase: PlaybackControlUseCaseProtocol
    )
    
    func loadInitialData()
    func refreshPlayback()
    func refreshRecentTracks()
    func playPause()
    func nextTrack()
    func previousTrack()
    func seek(to positionMs: Int)
    func startAutoRefresh()
    func stopAutoRefresh()
}

public final class SpotifyStateManager: SpotifyStateManagerProtocol {
    
    // MARK: - Singleton
    
    public static let shared = SpotifyStateManager()
    
    // MARK: - Private Properties
    
    private var getCurrentPlaybackUseCase: GetCurrentPlaybackUseCaseProtocol?
    private var getRecentlyPlayedUseCase: GetRecentlyPlayedUseCaseProtocol?
    private var playbackControlUseCase: PlaybackControlUseCaseProtocol?
    
    private let currentPlaybackRelay = BehaviorRelay<CurrentPlayback?>(value: nil)
    private let recentTracksRelay = BehaviorRelay<[RecentTrack]>(value: [])
    private let playbackDisplayRelay = BehaviorRelay<PlaybackDisplay?>(value: nil)
    private let errorRelay = PublishRelay<String?>()
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let lastPlaybackFetchTimeRelay = BehaviorRelay<Date?>(value: nil)
    
    private let disposeBag = DisposeBag()
    private let autoRefreshScheduler = SerialDispatchQueueScheduler(qos: .background)
    private var autoRefreshDisposable: Disposable?
    private var progressTimerDisposable: Disposable?
    
    // MARK: - Public Observable Properties
    
    public var currentPlayback: Observable<CurrentPlayback?> {
        currentPlaybackRelay.asObservable()
    }
    
    public var recentTracks: Observable<[RecentTrack]> {
        recentTracksRelay.asObservable()
    }
    
    public var playbackDisplay: Observable<PlaybackDisplay?> {
        playbackDisplayRelay.asObservable()
    }
    
    public var error: Observable<String?> {
        errorRelay.asObservable()
    }
    
    public var isLoading: Observable<Bool> {
        isLoadingRelay.asObservable()
    }
    
    // MARK: - Initializer
    
    private init() {
        setupBindings()
    }
    
    deinit {
        autoRefreshDisposable?.dispose()
        progressTimerDisposable?.dispose()
    }
    
    // MARK: - Public Methods
    
    public func configure(
        getCurrentPlaybackUseCase: GetCurrentPlaybackUseCaseProtocol,
        getRecentlyPlayedUseCase: GetRecentlyPlayedUseCaseProtocol,
        playbackControlUseCase: PlaybackControlUseCaseProtocol
    ) {
        self.getCurrentPlaybackUseCase = getCurrentPlaybackUseCase
        self.getRecentlyPlayedUseCase = getRecentlyPlayedUseCase
        self.playbackControlUseCase = playbackControlUseCase
    }
    
    public func loadInitialData() {
        isLoadingRelay.accept(true)
        
        Observable.zip(
            refreshPlaybackInternal(),
            refreshRecentTracksInternal()
        )
        .subscribe(
            onNext: { [weak self] _, _ in
                self?.isLoadingRelay.accept(false)
                self?.startAutoRefresh()
            },
            onError: { [weak self] error in
                self?.isLoadingRelay.accept(false)
                self?.errorRelay.accept(error.localizedDescription)
            }
        )
        .disposed(by: disposeBag)
    }
    
    public func refreshPlayback() {
        refreshPlaybackInternal()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    public func refreshRecentTracks() {
        refreshRecentTracksInternal()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    public func playPause() {
        guard let currentPlayback = currentPlaybackRelay.value else {
            errorRelay.accept("재생 중인 곡이 없습니다.")
            return
        }
        
        let action: () async throws -> Void = { [weak self] in
            guard let self,
                  let playbackControlUseCase = self.playbackControlUseCase else { return }
            
            if currentPlayback.isPlaying {
                try await playbackControlUseCase.pause()
            } else {
                try await playbackControlUseCase.play()
            }
        }
        
        performPlaybackControlAction(action: action)
    }
    
    public func nextTrack() {
        performPlaybackControlAction { [weak self] in
            guard let self,
                  let playbackControlUseCase = self.playbackControlUseCase else { return }
            try await playbackControlUseCase.nextTrack()
        }
    }
    
    public func previousTrack() {
        performPlaybackControlAction { [weak self] in
            guard let self,
                  let playbackControlUseCase = self.playbackControlUseCase else { return }
            try await playbackControlUseCase.previousTrack()
        }
    }
    
    public func seek(to positionMs: Int) {
        performPlaybackControlAction { [weak self] in
            guard let self,
                  let playbackControlUseCase = self.playbackControlUseCase else { return }
            try await playbackControlUseCase.seek(to: positionMs)
        }
    }
    
    public func startAutoRefresh() {
        autoRefreshDisposable?.dispose()
        
        autoRefreshDisposable = Observable<Int>
            .interval(.seconds(10), scheduler: autoRefreshScheduler)
            .subscribe(onNext: { [weak self] _ in
                self?.refreshPlayback()
            })
    }
    
    public func stopAutoRefresh() {
        autoRefreshDisposable?.dispose()
    }
}

// MARK: - Private Methods

private extension SpotifyStateManager {
    
    func setupBindings() {
        currentPlaybackRelay
            .subscribe(onNext: { [weak self] playback in
                self?.updatePlaybackDisplay(with: playback)
                self?.manageProgressTimer(for: playback)
            })
            .disposed(by: disposeBag)
    }
    
    func refreshPlaybackInternal() -> Observable<Void> {
        guard let getCurrentPlaybackUseCase = getCurrentPlaybackUseCase else {
            return .error(NSError(domain: "SpotifyStateManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "UseCase가 설정되지 않았습니다."]))
        }
        
        return Observable.create { [weak self] observer in
            Task {
                guard let self else { return }
                do {
                    let playback = try await getCurrentPlaybackUseCase.execute()
                    self.lastPlaybackFetchTimeRelay.accept(Date())
                    self.currentPlaybackRelay.accept(playback)
                    observer.onNext(())
                } catch let error as SpotifyRepositoryError {
                    switch error {
                    case .noCurrentlyPlaying:
                        self.currentPlaybackRelay.accept(nil)
                        observer.onNext(())
                    case .unauthorized:
                        observer.onError(NSError(domain: "SpotifyStateManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "Spotify 인증이 만료되었습니다. 다시 로그인해주세요."]))
                    case .networkError, .unknown:
                        self.currentPlaybackRelay.accept(nil)
                        observer.onNext(())
                    }
                } catch {
                    self.currentPlaybackRelay.accept(nil)
                    observer.onNext(())
                }
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    func refreshRecentTracksInternal() -> Observable<Void> {
        guard let getRecentlyPlayedUseCase = getRecentlyPlayedUseCase else {
            return .error(NSError(domain: "SpotifyStateManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "UseCase가 설정되지 않았습니다."]))
        }
        
        return Observable.create { [weak self] observer in
            Task {
                guard let self else { return }
                do {
                    let tracks = try await getRecentlyPlayedUseCase.execute(limit: 5)
                    self.recentTracksRelay.accept(tracks)
                    observer.onNext(())
                } catch SpotifyRepositoryError.unauthorized {
                    observer.onError(NSError(domain: "SpotifyStateManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "Spotify 인증이 만료되었습니다. 다시 로그인해주세요."]))
                } catch {
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    func performPlaybackControlAction(action: @escaping () async throws -> Void) {
        Observable<Void>.create { [weak self] observer in
            Task {
                guard let self else {
                    observer.onCompleted()
                    return
                }
                
                do {
                    try await action()
                    
                    // 0.5초 후 재생 상태 업데이트
                    try await Task.sleep(nanoseconds: 500_000_000)
                    
                    // 원격 플레이어 상태를 다시 불러와서 UI 업데이트
                    self.refreshPlayback()
                    observer.onNext(())
                    
                } catch SpotifyRepositoryError.unauthorized {
                    self.errorRelay.accept("Spotify 인증이 만료되었습니다. 다시 로그인해주세요.")
                } catch {
                    self.errorRelay.accept(error.localizedDescription)
                }
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
        .subscribe()
        .disposed(by: disposeBag)
    }
    
    func updatePlaybackDisplay(with playback: CurrentPlayback?) {
        if let playback,
           let track = playback.track {
            let display = PlaybackDisplay(
                track: track,
                isPlaying: playback.isPlaying,
                currentProgressMs: playback.progressMs ?? 0
            )
            playbackDisplayRelay.accept(display)
        } else {
            playbackDisplayRelay.accept(nil)
        }
    }
    
    func manageProgressTimer(for playback: CurrentPlayback?) {
        progressTimerDisposable?.dispose()
        
        guard let playback,
              playback.isPlaying,
              playback.track != nil else {
            return
        }
        
        progressTimerDisposable = Observable<Int>
            .interval(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.updateProgressTick()
            })
    }
    
    func updateProgressTick() {
        guard let currentPlayback = currentPlaybackRelay.value,
              let track = currentPlayback.track,
              currentPlayback.isPlaying else {
            return
        }
        
        let currentTime = Date().timeIntervalSince1970 * 1000
        let lastFetchTime = lastPlaybackFetchTimeRelay.value?.timeIntervalSince1970 ?? (currentTime / 1000)
        let elapsedTime = currentTime - lastFetchTime * 1000
        let originalProgressMs = currentPlayback.progressMs ?? 0
        
        var newProgressMs = originalProgressMs + Int(elapsedTime)
        newProgressMs = min(newProgressMs, track.durationMs)
        
        let updatedDisplay = PlaybackDisplay(
            track: track,
            isPlaying: currentPlayback.isPlaying,
            currentProgressMs: newProgressMs
        )
        
        playbackDisplayRelay.accept(updatedDisplay)
    }
}
