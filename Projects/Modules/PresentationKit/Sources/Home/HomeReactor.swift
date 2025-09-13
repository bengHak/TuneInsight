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
    }
    
    // MARK: - Mutation
    
    public enum Mutation {
        case setLoading(Bool)
        case setCurrentPlayback(CurrentPlayback?)
        case setRecentTracks([RecentTrack])
        case setError(String?)
        case setLastPlaybackFetchTime(Date)
        case setPlaybackDisplay(PlaybackDisplay?)
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
    
    
    // MARK: - Properties
    
    public let initialState = State()
    
    private let spotifyStateManager: SpotifyStateManagerProtocol
    
    // MARK: - Initializer
    
    public init(spotifyStateManager: SpotifyStateManagerProtocol) {
        self.spotifyStateManager = spotifyStateManager
    }
    
    deinit {}
    
    // MARK: - Mutate
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            spotifyStateManager.loadInitialData()
            return .empty()
            
        case .refresh:
            spotifyStateManager.refreshPlayback()
            spotifyStateManager.refreshRecentTracks()
            return .empty()
            
        case .refreshPlayback:
            spotifyStateManager.refreshPlayback()
            return .empty()
            
        case .playPause:
            spotifyStateManager.playPause()
            return .empty()
            
        case .nextTrack:
            spotifyStateManager.nextTrack()
            return .empty()
            
        case .previousTrack:
            spotifyStateManager.previousTrack()
            return .empty()
            
        case .seek(let positionMs):
            spotifyStateManager.seek(to: positionMs)
            return .empty()
            
        case .startAutoRefresh:
            spotifyStateManager.startAutoRefresh()
            return .empty()
            
        case .stopAutoRefresh:
            spotifyStateManager.stopAutoRefresh()
            return .empty()
        }
    }
    
    // MARK: - Transform
    
    public func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let spotifyMutations = Observable.merge([
            spotifyStateManager.currentPlayback
                .map { Mutation.setCurrentPlayback($0) },
            
            spotifyStateManager.recentTracks
                .map { Mutation.setRecentTracks($0) },
            
            spotifyStateManager.playbackDisplay
                .map { Mutation.setPlaybackDisplay($0) },
            
            spotifyStateManager.error
                .compactMap { $0 }
                .map { Mutation.setError($0) },
            
            spotifyStateManager.isLoading
                .map { Mutation.setLoading($0) }
        ])
        
        return Observable.merge(mutation, spotifyMutations)
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
            
        case .setRecentTracks(let tracks):
            newState.recentTracks = tracks
            newState.errorMessage = nil
            
        case .setError(let error):
            newState.errorMessage = error
            
        case .setLastPlaybackFetchTime(let date):
            newState.lastPlaybackFetchTime = date
            
        case .setPlaybackDisplay(let display):
            newState.playbackDisplay = display
        }
        
        return newState
    }
    
}
