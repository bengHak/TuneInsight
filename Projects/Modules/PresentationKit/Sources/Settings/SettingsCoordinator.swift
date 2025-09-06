import UIKit

public protocol SettingsCoordinatorDelegate: AnyObject {
    func settingsCoordinatorDidFinish(_ coordinator: SettingsCoordinator)
    func settingsCoordinatorDidLogout(_ coordinator: SettingsCoordinator)
}

public final class SettingsCoordinator {
    public var childCoordinators: [AnyObject] = []
    public let navigationController: UINavigationController
    public weak var delegate: SettingsCoordinatorDelegate?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() -> UIViewController {
        let settingsReactor = SettingsReactor()
        let settingsVC = SettingsViewController(reactor: settingsReactor)
        settingsVC.coordinator = self
        return settingsVC
    }
    
    public func removeChild(_ child: AnyObject) {
        childCoordinators.removeAll { $0 === child }
    }
    
    public func didLogout() {
        delegate?.settingsCoordinatorDidLogout(self)
    }
}