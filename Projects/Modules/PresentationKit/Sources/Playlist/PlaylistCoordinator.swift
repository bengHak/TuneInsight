import UIKit

public protocol PlaylistCoordinatorDelegate: AnyObject {
    func playlistCoordinatorDidFinish(_ coordinator: PlaylistCoordinator)
}

public final class PlaylistCoordinator {
    public var childCoordinators: [AnyObject] = []
    public let navigationController: UINavigationController
    public weak var delegate: PlaylistCoordinatorDelegate?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() -> UIViewController {
        let playlistReactor = PlaylistReactor()
        let playlistVC = PlaylistViewController(reactor: playlistReactor)
        playlistVC.coordinator = self
        return playlistVC
    }
    
    public func removeChild(_ child: AnyObject) {
        childCoordinators.removeAll { $0 === child }
    }
}