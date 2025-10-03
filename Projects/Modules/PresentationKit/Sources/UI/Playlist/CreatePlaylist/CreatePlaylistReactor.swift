import ReactorKit
import RxSwift
import DomainKit

public final class CreatePlaylistReactor: Reactor {
    public enum Action {
        case updateName(String)
        case updateDescription(String)
        case togglePublic(Bool)
        case toggleCollaborative(Bool)
        case createPlaylist
        case dismiss
    }

    public enum Mutation {
        case setName(String)
        case setDescription(String)
        case setPublic(Bool)
        case setCollaborative(Bool)
        case setLoading(Bool)
        case setError(String?)
        case setCreatedPlaylist(Playlist)
        case setDismiss
    }

    public struct State {
        public var name: String = ""
        public var description: String = ""
        public var isPublic: Bool = true
        public var isCollaborative: Bool = false
        public var isLoading: Bool = false
        public var errorMessage: String?
        public var createdPlaylist: Playlist?
        public var shouldDismiss: Bool = false

        public var isNameValid: Bool {
            return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        public var canCreate: Bool {
            return isNameValid && !isLoading
        }
    }

    public let initialState = State()
    private let createPlaylistUseCase: CreatePlaylistUseCaseProtocol

    public init(
        createPlaylistUseCase: CreatePlaylistUseCaseProtocol
    ) {
        self.createPlaylistUseCase = createPlaylistUseCase
    }

    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateName(let name):
            return .just(.setName(name))

        case .updateDescription(let description):
            return .just(.setDescription(description))

        case .togglePublic(let isPublic):
            return .just(.setPublic(isPublic))

        case .toggleCollaborative(let isCollaborative):
            return .just(.setCollaborative(isCollaborative))

        case .createPlaylist:
            return createPlaylist()

        case .dismiss:
            return .just(.setDismiss)
        }
    }

    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .setName(let name):
            newState.name = name
            newState.errorMessage = nil

        case .setDescription(let description):
            newState.description = description

        case .setPublic(let isPublic):
            newState.isPublic = isPublic

        case .setCollaborative(let isCollaborative):
            newState.isCollaborative = isCollaborative

        case .setLoading(let isLoading):
            newState.isLoading = isLoading

        case .setError(let error):
            newState.errorMessage = error
            newState.isLoading = false

        case .setCreatedPlaylist(let playlist):
            newState.createdPlaylist = playlist
            newState.isLoading = false
            newState.shouldDismiss = true

        case .setDismiss:
            newState.shouldDismiss = true
        }

        return newState
    }

    private func createPlaylist() -> Observable<Mutation> {
        let trimmedName = currentState.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = currentState.description.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            return .just(.setError("플레이리스트 이름을 입력해주세요."))
        }

        let description = trimmedDescription.isEmpty ? nil : trimmedDescription

        return Observable.concat([
            .just(.setLoading(true)),
            Observable.create { observer in
                Task {
                    do {
                        let playlist = try await self.createPlaylistUseCase.execute(
                            name: trimmedName,
                            description: description,
                            isPublic: self.currentState.isPublic
                        )
                        observer.onNext(.setCreatedPlaylist(playlist))
                        observer.onCompleted()
                    } catch {
                        let errorMessage: String
                        if let repositoryError = error as? SpotifyRepositoryError {
                            switch repositoryError {
                            case .unauthorized:
                                errorMessage = "인증이 필요합니다. 다시 로그인해주세요."
                            case .networkError:
                                errorMessage = "네트워크 연결을 확인해주세요."
                            default:
                                errorMessage = "플레이리스트 생성에 실패했습니다."
                            }
                        } else {
                            errorMessage = "플레이리스트 생성에 실패했습니다."
                        }
                        observer.onNext(.setError(errorMessage))
                        observer.onCompleted()
                    }
                }
                return Disposables.create()
            }
        ])
    }
}