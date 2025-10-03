import UIKit
import Then
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa
import DomainKit
import FoundationKit

public final class TrackDetailViewController: UIViewController, ReactorKit.View {
    public var disposeBag = DisposeBag()

    private let rootView = TrackDetailView()
    private let playerView = PlayerView()
    weak var coordinator: TrackDetailCoordinator?

    public init(reactor: TrackDetailReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        view = rootView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonDisplayMode = .minimal
        setupUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent, let coordinator {
            coordinator.delegate?.trackDetailCoordinatorDidFinish(coordinator)
        }
    }

    private func setupUI() {
        title = "track.detailTitle".localized()
        playerView.delegate = self
        rootView.playerContainerView.addSubview(playerView)
        playerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        rootView.didSelectAlbum = { [weak self] album in
            self?.showAlbumDetail(album: album)
        }
    }

    // MARK: - Reactor Binding
    public func bind(reactor: TrackDetailReactor) {
        // View lifecycle
        rx.methodInvoked(#selector(viewDidLoad))
            .map { _ in TrackDetailReactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Populate track details
        Observable.just(reactor.currentState.track)
            .bind { [weak self] track in
                self?.rootView.update(with: track)
            }
            .disposed(by: disposeBag)

        // Actions
        rootView.addToQueueButton.rx.tap
            .map { TrackDetailReactor.Action.addToQueue }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        rootView.skipNextButton.rx.tap
            .map { TrackDetailReactor.Action.playNow }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Pull-to-refresh binding
        rootView.refreshControl?.rx.controlEvent(.valueChanged)
            .map { TrackDetailReactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // State bindings
        reactor.state.map { $0.errorMessage }
            .distinctUntilChanged { ($0 ?? "") == ($1 ?? "") }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] message in
                self?.showError(message: message)
            }
            .disposed(by: disposeBag)

        reactor.state.map { $0.isProcessing }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] processing in
                self?.setButtonsEnabled(!processing)
            }
            .disposed(by: disposeBag)

        reactor.state.map { $0.isRefreshing }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] refreshing in
                if !refreshing {
                    self?.rootView.refreshControl?.endRefreshing()
                }
            }
            .disposed(by: disposeBag)

        // PlayerView playback updates
        reactor.playbackDisplay
            .observe(on: MainScheduler.instance)
            .bind { [weak self] display in
                self?.playerView.updatePlaybackDisplay(display)
            }
            .disposed(by: disposeBag)
    }

    private func setButtonsEnabled(_ enabled: Bool) {
        rootView.addToQueueButton.isEnabled = enabled
        rootView.skipNextButton.isEnabled = enabled
        rootView.addToQueueButton.alpha = enabled ? 1.0 : 0.5
        rootView.skipNextButton.alpha = enabled ? 1.0 : 0.5
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "common.error".localized(), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "common.confirm".localized(), style: .default))
        present(alert, animated: true)
    }

    private func showAlbumDetail(album: SpotifyAlbum) {
        coordinator?.showAlbumDetail(album: album)
    }
}

// MARK: - PlayerViewDelegate
extension TrackDetailViewController: PlayerViewDelegate {
    public func playerView(_ playerView: PlayerView, didTapPlayPause isPlaying: Bool) {
        reactor?.action.onNext(.playPause)
    }

    public func playerView(_ playerView: PlayerView, didTapNext: Void) {
        reactor?.action.onNext(.skipToNext)
    }

    public func playerView(_ playerView: PlayerView, didTapPrevious: Void) {
        // 현재 화면 요구사항 범위 밖이므로 미구현
    }

    public func playerView(_ playerView: PlayerView, didSeekTo positionMs: Int) {
        reactor?.action.onNext(.seek(positionMs: positionMs))
    }
}
