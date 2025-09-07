import SwiftUI
import UIKit
import Then
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa
import DomainKit

public final class HomeViewController: UIViewController, ReactorKit.View {
    public var disposeBag = DisposeBag()
    public weak var coordinator: HomeCoordinator?

    // MARK: - UI Components
    
    
    // MARK: - Initializer

    public init(reactor: HomeReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reactor?.action.onNext(.stopAutoRefresh)
    }

    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
    }


    // MARK: - Reactor Binding

    public func bind(reactor: HomeReactor) {
        bindActions(reactor)
        bindState(reactor)
    }
    
    private func bindActions(_ reactor: HomeReactor) {
        rx.methodInvoked(#selector(viewDidLoad))
            .map { _ in Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: HomeReactor) {
        reactor.state.map { $0.currentPlayback }
            .distinctUntilChanged()
            .bind { currentPlayback in
//                dump(currentPlayback)
            }.disposed(by: disposeBag)
        
        reactor.state.map { $0.recentTracks }
            .distinctUntilChanged()
            .bind { recentTrack in
                dump(recentTrack)
            }.disposed(by: disposeBag)
        
        reactor.state.map { $0.errorMessage }
            .distinctUntilChanged()
            .compactMap { $0 }
            .bind { message in
//                print(message)
            }.disposed(by: disposeBag)
    }
    
}
