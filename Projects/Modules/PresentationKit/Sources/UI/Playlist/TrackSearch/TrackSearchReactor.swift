import Foundation
import ReactorKit
import RxSwift
import DomainKit
import FoundationKit

public final class TrackSearchReactor: Reactor {
    public enum Action {
        case updateSearchText(String)
        case search(String)
        case loadMore
        case selectTrack(SearchTrackResult)
        case deselectTrack(SearchTrackResult)
        case addSelectedTracksToPlaylist
        case clearSelection
    }

    public enum Mutation {
        case setSearchText(String)
        case setSearchResults([SearchTrackResult])
        case appendSearchResults([SearchTrackResult])
        case setLoading(Bool)
        case setLoadingMore(Bool)
        case setError(String?)
        case setSelectedTracks(Set<String>)
        case setAddingTracks(Bool)
        case setSuccess(String?)
    }

    public struct State {
        public var searchText: String = ""
        public var searchResults: [SearchTrackResult] = []
        public var selectedTrackIds: Set<String> = []
        public var isLoading: Bool = false
        public var isLoadingMore: Bool = false
        public var isAddingTracks: Bool = false
        public var errorMessage: String?
        public var successMessage: String?
        public var hasMorePages: Bool = true
        public var currentOffset: Int = 0
        public let pageSize: Int = 20

        public var selectedTracks: [SearchTrackResult] {
            return searchResults.filter { selectedTrackIds.contains($0.id) }
        }

        public var selectedTracksCount: Int {
            return selectedTrackIds.count
        }
    }

    // MARK: - Properties

    public let initialState: State = .init()
    private let playlist: Playlist
    private let searchTracksUseCase: SearchTracksUseCaseProtocol
    private let addTracksToPlaylistUseCase: AddTracksToPlaylistUseCaseProtocol
    public weak var coordinator: TrackSearchCoordinator?

    // MARK: - Init

    public init(
        playlist: Playlist,
        searchTracksUseCase: SearchTracksUseCaseProtocol,
        addTracksToPlaylistUseCase: AddTracksToPlaylistUseCaseProtocol
    ) {
        self.playlist = playlist
        self.searchTracksUseCase = searchTracksUseCase
        self.addTracksToPlaylistUseCase = addTracksToPlaylistUseCase
    }

    // MARK: - Mutate

    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateSearchText(text):
            return .just(.setSearchText(text))

        case let .search(query):
            guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return Observable.concat([
                    .just(.setSearchResults([])),
                    .just(.setError(nil))
                ])
            }
            return searchTracks(query: query, isNewSearch: true)

        case .loadMore:
            guard !currentState.isLoadingMore && currentState.hasMorePages && !currentState.searchText.isEmpty else {
                return .empty()
            }
            return searchTracks(query: currentState.searchText, isNewSearch: false)

        case let .selectTrack(track):
            var selectedIds = currentState.selectedTrackIds
            selectedIds.insert(track.id)
            return .just(.setSelectedTracks(selectedIds))

        case let .deselectTrack(track):
            var selectedIds = currentState.selectedTrackIds
            selectedIds.remove(track.id)
            return .just(.setSelectedTracks(selectedIds))

        case .addSelectedTracksToPlaylist:
            guard !currentState.selectedTracks.isEmpty else { return .empty() }
            return addTracksToPlaylist()

        case .clearSelection:
            return .just(.setSelectedTracks([]))
        }
    }

    // MARK: - Reduce

    public func reduce(state: State, mutation: Mutation) -> State {
        var state = state

        switch mutation {
        case let .setSearchText(text):
            state.searchText = text

        case let .setSearchResults(results):
            state.searchResults = results
            state.currentOffset = results.count
            state.hasMorePages = results.count >= state.pageSize

        case let .appendSearchResults(results):
            state.searchResults.append(contentsOf: results)
            state.currentOffset += results.count
            state.hasMorePages = results.count >= state.pageSize

        case let .setLoading(isLoading):
            state.isLoading = isLoading

        case let .setLoadingMore(isLoadingMore):
            state.isLoadingMore = isLoadingMore

        case let .setError(message):
            state.errorMessage = message

        case let .setSelectedTracks(selectedIds):
            state.selectedTrackIds = selectedIds

        case let .setAddingTracks(isAdding):
            state.isAddingTracks = isAdding

        case let .setSuccess(message):
            state.successMessage = message
        }

        return state
    }

    // MARK: - Private Methods

    private func searchTracks(query: String, isNewSearch: Bool) -> Observable<Mutation> {
        let offset = isNewSearch ? 0 : currentState.currentOffset
        let loadingMutation: Mutation = isNewSearch ? .setLoading(true) : .setLoadingMore(true)
        let resultMutation: (([SearchTrackResult]) -> Mutation) = isNewSearch ?
            Mutation.setSearchResults : Mutation.appendSearchResults

        return Observable.concat([
            .just(loadingMutation),
            .just(.setError(nil)),
            Observable<Mutation>.create { [weak self] observer in
                guard let self = self else { return Disposables.create() }

                Task {
                    do {
                        let searchPage = try await self.searchTracksUseCase.execute(
                            query: query,
                            limit: self.currentState.pageSize,
                            offset: offset,
                            market: nil
                        )
                        observer.onNext(resultMutation(searchPage.items))
                        observer.onCompleted()
                    } catch {
                        observer.onNext(.setError(error.localizedDescription))
                        observer.onCompleted()
                    }
                }

                return Disposables.create()
            },
            .just(isNewSearch ? .setLoading(false) : .setLoadingMore(false))
        ])
    }

    private func addTracksToPlaylist() -> Observable<Mutation> {
        let selectedTracks = currentState.selectedTracks
        let trackUris = selectedTracks.map { $0.uri }

        return Observable.concat([
            .just(.setAddingTracks(true)),
            .just(.setError(nil)),
            Observable<Mutation>.create { [weak self] observer in
                guard let self = self else { return Disposables.create() }

                Task {
                    do {
                        _ = try await self.addTracksToPlaylistUseCase.execute(
                            playlistId: self.playlist.id,
                            trackUris: trackUris,
                            position: nil
                        )

                        let count = selectedTracks.count
                        let message = count == 1 ?
                            "playlist.addSingleTrackSuccess".localized() :
                            "playlist.addTracksSuccessCount".localizedFormat(count)

                        observer.onNext(.setSuccess(message))
                        observer.onNext(.setSelectedTracks([]))

                        // 성공 후 화면 닫기
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.coordinator?.finishTrackSearch()
                        }

                        observer.onCompleted()
                    } catch {
                        observer.onNext(.setError(error.localizedDescription))
                        observer.onCompleted()
                    }
                }

                return Disposables.create()
            },
            .just(.setAddingTracks(false))
        ])
    }
}
