import UIKit

public protocol StatisticsCoordinatorDelegate: AnyObject {
    func statisticsCoordinatorDidFinish(_ coordinator: StatisticsCoordinator)
}

public final class StatisticsCoordinator {
    public var childCoordinators: [AnyObject] = []
    public let navigationController: UINavigationController
    public weak var delegate: StatisticsCoordinatorDelegate?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() -> UIViewController {
        let statisticsReactor = StatisticsReactor()
        let statisticsVC = StatisticsViewController(reactor: statisticsReactor)
        statisticsVC.coordinator = self
        return statisticsVC
    }
    
    public func removeChild(_ child: AnyObject) {
        childCoordinators.removeAll { $0 === child }
    }
}