import UIKit
import DomainKit

public protocol CreatePlaylistCoordinator: AnyObject {
    func didFinish()
}

public final class CreatePlaylistCoordinatorImpl: CreatePlaylistCoordinator {
    private weak var navigationController: UINavigationController?
    private let createPlaylistUseCase: CreatePlaylistUseCaseProtocol
    public var onPlaylistCreated: ((Playlist) -> Void)?

    public init(
        navigationController: UINavigationController,
        createPlaylistUseCase: CreatePlaylistUseCaseProtocol
    ) {
        self.navigationController = navigationController
        self.createPlaylistUseCase = createPlaylistUseCase
    }

    public func start() {
        let reactor = CreatePlaylistReactor(
            createPlaylistUseCase: createPlaylistUseCase
        )

        let viewController = CreatePlaylistViewController(reactor: reactor)
        viewController.coordinator = self

        let presentingNavigationController = UINavigationController(rootViewController: viewController)
        presentingNavigationController.modalPresentationStyle = .formSheet
        presentingNavigationController.isModalInPresentation = true

        navigationController?.present(presentingNavigationController, animated: true)
    }

    public func didFinish() {
        navigationController?.dismiss(animated: true)
    }
}