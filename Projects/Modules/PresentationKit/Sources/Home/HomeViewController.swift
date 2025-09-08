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
    
    private lazy var playerView = PlayerView().then {
        $0.delegate = self
        $0.isHidden = false
    }
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
    }
    
    private let contentView = UIView()
    
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
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reactor?.action.onNext(.startAutoRefresh)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reactor?.action.onNext(.stopAutoRefresh)
    }

    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(playerView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        playerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        // contentView의 bottom constraint는 나중에 다른 뷰들이 추가되면 업데이트
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(playerView.snp.bottom)
        }
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
        reactor.state.map { $0.playbackDisplay }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] playbackDisplay in
                self?.updatePlayerView(with: playbackDisplay)
            }.disposed(by: disposeBag)
        
        reactor.state.map { $0.recentTracks }
            .distinctUntilChanged()
            .bind { recentTrack in
//                dump(recentTrack)
            }.disposed(by: disposeBag)
        
        
        reactor.state.map { $0.errorMessage }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .compactMap { $0 }
            .bind { [weak self] message in
                self?.showError(message: message)
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    
    private func updatePlayerView(with playbackDisplay: HomeReactor.PlaybackDisplay?) {
        playerView.updatePlaybackDisplay(playbackDisplay)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - PlayerViewDelegate

extension HomeViewController: PlayerViewDelegate {
    public func playerView(_ playerView: PlayerView, didTapPlayPause isPlaying: Bool) {
        reactor?.action.onNext(.playPause)
    }
    
    public func playerView(_ playerView: PlayerView, didTapNext: Void) {
        reactor?.action.onNext(.nextTrack)
    }
    
    public func playerView(_ playerView: PlayerView, didTapPrevious: Void) {
        reactor?.action.onNext(.previousTrack)
    }
    
    public func playerView(_ playerView: PlayerView, didSeekTo positionMs: Int) {
        reactor?.action.onNext(.seek(positionMs: positionMs))
    }
}
