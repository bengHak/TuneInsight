import Foundation
import ReactorKit
import RxSwift
import DomainKit

public final class PlaylistListReactor: Reactor {
    public enum Action {
        case viewDidLoad
        case viewWillAppear
        case refresh
        case loadMore
        case createPlaylist
        case confirmCreatePlaylist(name: String, description: String?, isPublic: Bool)
        case selectPlaylist(Playlist)
        case deletePlaylist(Playlist)
    }

    public enum Mutation {
        case setPlaylists([Playlist])
        case appendPlaylists([Playlist])
        case setLoading(Bool)
        case setRefreshing(Bool)
        case setLoadingMore(Bool)
        case setError(String?)
        case setShowCreatePlaylist(Bool)
        case removePlaylist(String)
        case addPlaylist(Playlist)
    }

    public struct State {
        public var playlists: [Playlist] = []
        public var isLoading: Bool = false
        public var isRefreshing: Bool = false
        public var isLoadingMore: Bool = false
        public var errorMessage: String?
        public var shouldShowCreatePlaylist: Bool?
        public var hasMorePages: Bool = true
        public var currentOffset: Int = 0
        public let pageSize: Int = 20
    }

    // MARK: - Properties

    public let initialState: State = .init()
    private let getUserPlaylistsUseCase: GetUserPlaylistsUseCaseProtocol
    private let createPlaylistUseCase: CreatePlaylistUseCaseProtocol
    private let deletePlaylistUseCase: DeletePlaylistUseCaseProtocol
    public weak var coordinator: PlaylistCoordinator?

    // MARK: - Init

    public init(
        getUserPlaylistsUseCase: GetUserPlaylistsUseCaseProtocol,
        createPlaylistUseCase: CreatePlaylistUseCaseProtocol,
        deletePlaylistUseCase: DeletePlaylistUseCaseProtocol
    ) {
        self.getUserPlaylistsUseCase = getUserPlaylistsUseCase
        self.createPlaylistUseCase = createPlaylistUseCase
        self.deletePlaylistUseCase = deletePlaylistUseCase
    }

    // MARK: - Mutate

    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return loadPlaylists()

        case .viewWillAppear:
            // Refresh if needed
            return .empty()

        case .refresh:
            return refreshPlaylists()

        case .loadMore:
            guard !currentState.isLoadingMore && currentState.hasMorePages else { return .empty() }
            return loadMorePlaylists()

        case .createPlaylist:
            return .just(.setShowCreatePlaylist(true))

        case let .confirmCreatePlaylist(name, description, isPublic):
            return createPlaylist(name: name, description: description, isPublic: isPublic)

        case let .selectPlaylist(playlist):
            coordinator?.showPlaylistDetail(playlist: playlist)
            return .empty()

        case let .deletePlaylist(playlist):
            return deletePlaylist(playlist)
        }
    }

    // MARK: - Reduce

    public func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.shouldShowCreatePlaylist = nil

        switch mutation {
        case let .setPlaylists(playlists):
            state.playlists = playlists
            state.currentOffset = playlists.count
            state.hasMorePages = playlists.count >= state.pageSize

        case let .appendPlaylists(playlists):
            state.playlists.append(contentsOf: playlists)
            state.currentOffset += playlists.count
            state.hasMorePages = playlists.count >= state.pageSize

        case let .setLoading(isLoading):
            state.isLoading = isLoading

        case let .setRefreshing(isRefreshing):
            state.isRefreshing = isRefreshing

        case let .setLoadingMore(isLoadingMore):
            state.isLoadingMore = isLoadingMore

        case let .setError(message):
            state.errorMessage = message

        case let .setShowCreatePlaylist(show):
            state.shouldShowCreatePlaylist = show

        case let .removePlaylist(id):
            state.playlists.removeAll { $0.id == id }

        case let .addPlaylist(playlist):
            state.playlists.insert(playlist, at: 0)
        }

        return state
    }

    // MARK: - Private Methods

    private func loadPlaylists() -> Observable<Mutation> {
        return Observable.concat([
            .just(.setLoading(true)),
            .just(.setError(nil)),
            Observable<Mutation>.create { [weak self] observer in
                guard let self = self else { return Disposables.create() }

                Task {
                    do {
                        let page = try await self.getUserPlaylistsUseCase.execute(
                            limit: self.currentState.pageSize,
                            offset: 0
                        )
                        observer.onNext(.setPlaylists(page.items))
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

    private func refreshPlaylists() -> Observable<Mutation> {
        return Observable.concat([
            .just(.setRefreshing(true)),
            .just(.setError(nil)),
            Observable<Mutation>.create { [weak self] observer in
                guard let self = self else { return Disposables.create() }

                Task {
                    do {
                        let page = try await self.getUserPlaylistsUseCase.execute(
                            limit: self.currentState.pageSize,
                            offset: 0
                        )
                        observer.onNext(.setPlaylists(page.items))
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

    private func loadMorePlaylists() -> Observable<Mutation> {
        return Observable.concat([
            .just(.setLoadingMore(true)),
            Observable<Mutation>.create { [weak self] observer in
                guard let self = self else { return Disposables.create() }

                Task {
                    do {
                        let page = try await self.getUserPlaylistsUseCase.execute(
                            limit: self.currentState.pageSize,
                            offset: self.currentState.currentOffset
                        )
                        observer.onNext(.appendPlaylists(page.items))
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

    private func createPlaylist(name: String, description: String?, isPublic: Bool) -> Observable<Mutation> {
        return Observable.concat([
            .just(.setShowCreatePlaylist(false)),
            .just(.setLoading(true)),
            Observable<Mutation>.create { [weak self] observer in
                guard let self = self else { return Disposables.create() }

                Task {
                    do {
                        let playlist = try await self.createPlaylistUseCase.execute(
                            name: name,
                            description: description,
                            isPublic: isPublic
                        )
                        observer.onNext(.addPlaylist(playlist))
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

    private func deletePlaylist(_ playlist: Playlist) -> Observable<Mutation> {
        return Observable.concat([
            Observable<Mutation>.create { [weak self] observer in
                guard let self = self else { return Disposables.create() }

                Task {
                    do {
                        try await self.deletePlaylistUseCase.execute(playlistId: playlist.id)
                        observer.onNext(.removePlaylist(playlist.id))
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
