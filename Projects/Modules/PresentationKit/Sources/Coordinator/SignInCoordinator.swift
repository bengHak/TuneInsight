import UIKit
import RxSwift

public protocol SignInCoordinatorDelegate: AnyObject {
    func signInCoordinatorDidFinish(_ coordinator: SignInCoordinator)
}

public final class SignInCoordinator {
    public var childCoordinators: [AnyObject] = []
    public let navigationController: UINavigationController
    public weak var delegate: SignInCoordinatorDelegate?
    private let disposeBag = DisposeBag()
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let signInVC = SignInViewController()
        signInVC.coordinator = self
        signInVC.modalPresentationStyle = .fullScreen
        navigationController.present(signInVC, animated: true)
        
        observeAuthenticationState()
    }
    
    private func observeAuthenticationState() {
        SpotifyAuthManager.shared.authorizationState
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .authorized(_):
                    self?.handleAuthenticationSuccess()
                case .failed(_):
                    break
                case .idle, .authorizing:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func handleAuthenticationSuccess() {
        navigationController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.signInCoordinatorDidFinish(self)
        }
    }
    
    public func removeChild(_ child: AnyObject) {
        childCoordinators.removeAll { $0 === child }
    }
}