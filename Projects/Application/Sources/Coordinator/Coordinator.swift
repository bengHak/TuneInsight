import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get }
    
    func start()
    func removeChild(_ child: Coordinator)
}

extension Coordinator {
    func removeChild(_ child: Coordinator) {
        childCoordinators.removeAll { $0 === child }
    }
    
    func addChild(_ child: Coordinator) {
        childCoordinators.append(child)
    }
}