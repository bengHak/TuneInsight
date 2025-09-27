import Foundation
import ReactorKit
import RxSwift
import DomainKit

public final class PlaylistDetailReactor: Reactor {
    public enum Action {
        case viewDidLoad
        case refresh
        case loadMore
        case selectTrack(PlaylistTrack)
        case addTracks
        case editPlaylist
        case deleteTrack(PlaylistTrack)
        case updatePlaylist(name: String, description: String?, isPublic: Bool)
    }

    public enum Mutation {
        case setPlaylist(Playlist)
        case setTracks([PlaylistTrack])
        case appendTracks([PlaylistTrack])
        case setLoading(Bool)
        case setRefreshing(Bool)
        case setLoadingMore(Bool)
        case setError(String?)
        case setShowEditPlaylist(Bool)
        case removeTrack(String)
        case updatePlaylistInfo(Playlist)
    }

    public struct State {
        public var playlist: Playlist?
        public var tracks: [PlaylistTrack] = []
        public var isLoading: Bool = false
        public var isRefreshing: Bool = false
        public var isLoadingMore: Bool = false
        public var errorMessage: String?
        public var shouldShowEditPlaylist: Bool = false
        public var hasMorePages: Bool = true
        public var currentOffset: Int = 0
        public let pageSize: Int = 50
    }

    // MARK: - Properties

    public let initialState: State = .init()
    private let playlist: Playlist
    private let getPlaylistDetailUseCase: GetPlaylistDetailUseCaseProtocol
    private let updatePlaylistUseCase: UpdatePlaylistUseCaseProtocol
    private let removeTracksFromPlaylistUseCase: RemoveTracksFromPlaylistUseCaseProtocol
    public weak var coordinator: PlaylistDetailCoordinator?

    // MARK: - Init

    public init(
        playlist: Playlist,
        getPlaylistDetailUseCase: GetPlaylistDetailUseCaseProtocol,
        updatePlaylistUseCase: UpdatePlaylistUseCaseProtocol,
        removeTracksFromPlaylistUseCase: RemoveTracksFromPlaylistUseCaseProtocol
    ) {
        self.playlist = playlist
        self.getPlaylistDetailUseCase = getPlaylistDetailUseCase
        self.updatePlaylistUseCase = updatePlaylistUseCase
        self.removeTracksFromPlaylistUseCase = removeTracksFromPlaylistUseCase
    }

    // MARK: - Mutate

    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return loadPlaylistDetail()

        case .refresh:
            return refreshPlaylist()

        case .loadMore:
            guard !currentState.isLoadingMore && currentState.hasMorePages else { return .empty() }
            return loadMoreTracks()

        case let .selectTrack(track):
            coordinator?.showTrackDetail(track: track)
            return .empty()

        case .addTracks:
            guard let playlist = currentState.playlist else { return .empty() }
            coordinator?.showTrackSearch(playlist: playlist)
            return .empty()

        case .editPlaylist:
            return .just(.setShowEditPlaylist(true))

        case let .deleteTrack(track):
            return removeTrack(track)

        case let .updatePlaylist(name, description, isPublic):
            return updatePlaylist(name: name, description: description, isPublic: isPublic)
        }
    }

    // MARK: - Reduce

    public func reduce(state: State, mutation: Mutation) -> State {
        var state = state

        switch mutation {
        case let .setPlaylist(playlist):
            state.playlist = playlist

        case let .setTracks(tracks):
            state.tracks = tracks
            state.currentOffset = tracks.count
            state.hasMorePages = tracks.count >= state.pageSize

        case let .appendTracks(tracks):
            state.tracks.append(contentsOf: tracks)
            state.currentOffset += tracks.count
            state.hasMorePages = tracks.count >= state.pageSize

        case let .setLoading(isLoading):
            state.isLoading = isLoading

        case let .setRefreshing(isRefreshing):
            state.isRefreshing = isRefreshing

        case let .setLoadingMore(isLoadingMore):
            state.isLoadingMore = isLoadingMore

        case let .setError(message):
            state.errorMessage = message

        case let .setShowEditPlaylist(show):
            state.shouldShowEditPlaylist = show

        case let .removeTrack(uri):
            state.tracks.removeAll { $0.uri == uri }

        case let .updatePlaylistInfo(playlist):
            state.playlist = playlist
        }

        return state
    }

    // MARK: - Private Methods

    private func loadPlaylistDetail() -> Observable<Mutation> {
        return Observable.concat([
            .just(.setLoading(true)),
            .just(.setError(nil)),
            .just(.setPlaylist(playlist)),
            Observable<Mutation>.create { [weak self] observer in
                guard let self = self else { return Disposables.create() }

                Task {
                    do {
                        let tracksPage = try await self.getPlaylistDetailUseCase.getPlaylistTracks(
                            playlistId: self.playlist.id,
                            limit: self.currentState.pageSize,
                            offset: 0
                        )
                        observer.onNext(.setTracks(tracksPage.items))
                        observer.onCompleted()
                    } catch {
                        observer.onNext(.setError(error.localizedDescription))
                        observer.onCompleted()
                    }
                }

                return Disposables.create()
            },
            .just(.setLoading(false))
        ])
    }

    private func refreshPlaylist() -> Observable<Mutation> {
        return Observable.concat([
            .just(.setRefreshing(true)),
            .just(.setError(nil)),
            Observable<Mutation>.create { [weak self] observer in
                guard let self = self else { return Disposables.create() }

                Task {
                    do {
                        // Get updated playlist info
                        let playlist = try await self.getPlaylistDetailUseCase.execute(playlistId: self.playlist.id)
                        observer.onNext(.updatePlaylistInfo(playlist))

                        // Get fresh tracks
                        let tracksPage = try await self.getPlaylistDetailUseCase.getPlaylistTracks(
                            playlistId: self.playlist.id,
                            limit: self.currentState.pageSize,
                            offset: 0
                        )
                        observer.onNext(.setTracks(tracksPage.items))
                        observer.onCompleted()
                    } catch {
                        observer.onNext(.setError(error.localizedDescription))
                        observer.onCompleted()
                    }
                }

                return Disposables.create()
            },
            .just(.setRefreshing(false))
        ])
    }

    private func loadMoreTracks() -> Observable<Mutation> {
        return Observable.concat([
            .just(.setLoadingMore(true)),
            Observable<Mutation>.create { [weak self] observer in
                guard let self = self else { return Disposables.create() }

                Task {
                    do {
                        let tracksPage = try await self.getPlaylistDetailUseCase.getPlaylistTracks(
                            playlistId: self.playlist.id,
                            limit: self.currentState.pageSize,
                            offset: self.currentState.currentOffset
                        )
                        observer.onNext(.appendTracks(tracksPage.items))
                        observer.onCompleted()
                    } catch {
                        observer.onNext(.setError(error.localizedDescription))
                        observer.onCompleted()
                    }
                }

                return Disposables.create()
            },
            .just(.setLoadingMore(false))
        ])
    }

    private func removeTrack(_ track: PlaylistTrack) -> Observable<Mutation> {
        return Observable.concat([
            Observable<Mutation>.create { [weak self] observer in
                guard let self = self else { return Disposables.create() }

                Task {
                    do {
                        _ = try await self.removeTracksFromPlaylistUseCase.execute(
                            playlistId: self.playlist.id,
                            trackUris: [track.uri],
                            snapshotId: nil
                        )
                        observer.onNext(.removeTrack(track.uri))
                        observer.onCompleted()
                    } catch {
                        observer.onNext(.setError(error.localizedDescription))
                        observer.onCompleted()
                    }
                }

                return Disposables.create()
            }
        ])
    }

    private func updatePlaylist(name: String, description: String?, isPublic: Bool) -> Observable<Mutation> {
        return Observable.concat([
            .just(.setShowEditPlaylist(false)),
            Observable<Mutation>.create { [weak self] observer in
                guard let self = self else { return Disposables.create() }

                Task {
                    do {
                        try await self.updatePlaylistUseCase.execute(
                            playlistId: self.playlist.id,
                            name: name,
                            description: description,
                            isPublic: isPublic
                        )

                        // Fetch updated playlist info
                        let updatedPlaylist = try await self.getPlaylistDetailUseCase.execute(playlistId: self.playlist.id)
                        observer.onNext(.updatePlaylistInfo(updatedPlaylist))
                        observer.onCompleted()
                    } catch {
                        observer.onNext(.setError(error.localizedDescription))
                        observer.onCompleted()
                    }
                }

                return Disposables.create()
            }
        ])
    }
}