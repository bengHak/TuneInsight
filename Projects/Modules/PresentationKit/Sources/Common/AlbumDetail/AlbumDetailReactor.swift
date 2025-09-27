import Foundation
import ReactorKit
import RxSwift
import DomainKit

public final class AlbumDetailReactor: Reactor {
    // MARK: - Action
    public enum Action {
        case viewDidLoad
    }

    // MARK: - Mutation
    public enum Mutation {
        case setTracks([SpotifyAlbumTrack])
        case setLoading(Bool)
        case setError(String?)
    }

    // MARK: - State
    public struct State {
        public let album: SpotifyAlbum
        public var tracks: [SpotifyAlbumTrack] = []
        public var isLoading: Bool = false
        public var errorMessage: String?

        public init(album: SpotifyAlbum) {
            self.album = album
        }
    }

    public let initialState: State

    // MARK: - Dependencies
    private let getAlbumTracksUseCase: GetAlbumTracksUseCaseProtocol

    // MARK: - Init
    public init(
        album: SpotifyAlbum,
        getAlbumTracksUseCase: GetAlbumTracksUseCaseProtocol
    ) {
        self.initialState = State(album: album)
        self.getAlbumTracksUseCase = getAlbumTracksUseCase
    }

    // MARK: - Mutate
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            let clearError = Observable.just(Mutation.setError(nil))
            let loadTracks = Observable<Mutation>.create { [weak self] observer in
                Task { [weak self] in
                    guard let self else {
                        observer.onCompleted()
                        return
                    }
                    do {
                        let tracks = try await self.fetchAllTracks(albumId: self.currentState.album.id)
                        observer.onNext(.setTracks(tracks))
                    } catch {
                        observer.onNext(.setError(error.localizedDescription))
                    }
                    observer.onCompleted()
                }
                return Disposables.create()
            }

            return Observable.concat([
                clearError,
                .just(.setLoading(true)),
                loadTracks,
                .just(.setLoading(false))
            ])
        }
    }

    // MARK: - Reduce
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setTracks(let tracks):
            newState.tracks = tracks
        case .setLoading(let loading):
            newState.isLoading = loading
        case .setError(let message):
            newState.errorMessage = message
        }
        return newState
    }
}

// MARK: - Private Helpers
private extension AlbumDetailReactor {
    func fetchAllTracks(albumId: String) async throws -> [SpotifyAlbumTrack] {
        var accumulated: [SpotifyAlbumTrack] = []
        var offset = 0
        let limit = 50
        var total = Int.max

        while offset < total {
            let page = try await getAlbumTracksUseCase.execute(albumId: albumId, limit: limit, offset: offset)
            accumulated.append(contentsOf: page.items)
            total = page.total
            guard page.limit > 0 else { break }
            offset += page.limit
            if page.next == nil { break }
        }

        return accumulated
    }
}
