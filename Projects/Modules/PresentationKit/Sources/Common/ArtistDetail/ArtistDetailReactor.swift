import Foundation
import ReactorKit
import RxSwift
import DomainKit

public final class ArtistDetailReactor: Reactor {
    // MARK: - Action
    public enum Action {
        case viewDidLoad
    }

    // MARK: - Mutation
    public enum Mutation {
        case setAlbums([SpotifyAlbum])
        case setTopTracks([SpotifyTrack])
        case setError(String?)
        case setLoading(Bool)
    }

    // MARK: - State
    public struct State {
        public let artist: SpotifyArtist
        public var albums: [SpotifyAlbum] = []
        public var topTracks: [SpotifyTrack] = []
        public var isLoading: Bool = false
        public var errorMessage: String?
        public init(artist: SpotifyArtist) { self.artist = artist }
    }

    public let initialState: State

    // MARK: - Dependencies
    private let getArtistAlbumsUseCase: GetArtistAlbumsUseCaseProtocol
    private let getArtistTopTracksUseCase: GetArtistTopTracksUseCaseProtocol

    // MARK: - Init
    public init(
        artist: SpotifyArtist,
        getArtistAlbumsUseCase: GetArtistAlbumsUseCaseProtocol,
        getArtistTopTracksUseCase: GetArtistTopTracksUseCaseProtocol
    ) {
        self.initialState = State(artist: artist)
        self.getArtistAlbumsUseCase = getArtistAlbumsUseCase
        self.getArtistTopTracksUseCase = getArtistTopTracksUseCase
    }

    // MARK: - Mutate
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            let artistId = currentState.artist.id
            let loadAlbums = Observable<Mutation>.create { observer in
                Task {
                    do {
                        let albums = try await self.getArtistAlbumsUseCase.execute(artistId: artistId, limit: 20, offset: 0)
                        observer.onNext(.setAlbums(albums))
                    } catch {
                        observer.onNext(.setError(error.localizedDescription))
                    }
                    observer.onCompleted()
                }
                return Disposables.create()
            }

            let loadTopTracks = Observable<Mutation>.create { observer in
                Task {
                    do {
                        let tracks = try await self.getArtistTopTracksUseCase.execute(artistId: artistId, market: "US")
                        observer.onNext(.setTopTracks(tracks))
                    } catch {
                        observer.onNext(.setError(error.localizedDescription))
                    }
                    observer.onCompleted()
                }
                return Disposables.create()
            }

            return Observable.concat([
                .just(.setLoading(true)),
                Observable.merge(loadAlbums, loadTopTracks),
                .just(.setLoading(false))
            ])
        }
    }

    // MARK: - Reduce
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setAlbums(let albums):
            newState.albums = albums
        case .setTopTracks(let tracks):
            newState.topTracks = tracks
        case .setError(let message):
            newState.errorMessage = message
        case .setLoading(let loading):
            newState.isLoading = loading
        }
        return newState
    }
}

