import UIKit
import DomainKit
import DIKit

public protocol HomeCoordinatorDelegate: AnyObject {
    func homeCoordinatorDidFinish(_ coordinator: HomeCoordinator)
}

public final class HomeCoordinator {
    public var childCoordinators: [AnyObject] = []
    public let navigationController: UINavigationController
    public weak var delegate: HomeCoordinatorDelegate?
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() -> UIViewController {
        // DIContainer에서 HomeReactor resolve
        guard let homeReactor = resolve(HomeReactor.self) else {
            fatalError("HomeReactor를 resolve할 수 없습니다. DI 설정을 확인해주세요.")
        }
        
        // ViewController 생성
        let homeVC = HomeViewController(reactor: homeReactor)
        homeVC.coordinator = self
        return homeVC
    }
    
    public func removeChild(_ child: AnyObject) {
        childCoordinators.removeAll { $0 === child }
    }
}
