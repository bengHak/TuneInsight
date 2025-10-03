import UIKit
import ReactorKit
import RxSwift
import DomainKit
import SnapKit

public final class AlbumDetailViewController: UIViewController, ReactorKit.View {
    public var disposeBag = DisposeBag()

    private let rootView = AlbumDetailView()
    weak var coordinator: AlbumDetailCoordinator?

    // MARK: - Init
    public init(reactor: AlbumDetailReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonDisplayMode = .minimal
        setupUI()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent, let coordinator {
            coordinator.delegate?.albumDetailCoordinatorDidFinish(coordinator)
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerCopyButton()
    }

    // MARK: - Setup
    private func setupUI() {
        title = "앨범 상세"
        view.addSubview(rootView)
        rootView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }

        rootView.didSelectTrack = { [weak self] track in
            self?.showTrackDetail(track: track)
        }
    }

    private func registerCopyButton() {
        guard let button = rootView.copyURIButton else { return }
        button.removeTarget(self, action: #selector(copyURITapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(copyURITapped), for: .touchUpInside)
    }

    private func configure(with album: SpotifyAlbum) {
        rootView.configure(with: album)
        DispatchQueue.main.async { [weak self] in
            self?.registerCopyButton()
        }
    }

    // MARK: - Actions
    @objc private func copyURITapped() {
        guard let album = reactor?.currentState.album else { return }
        UIPasteboard.general.string = album.uri
        let alert = UIAlertController(title: nil, message: "URI가 복사되었습니다.", preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak alert] in
            alert?.dismiss(animated: true)
        }
    }
}

// MARK: - Bindings
public extension AlbumDetailViewController {
    func bind(reactor: AlbumDetailReactor) {
        rx.methodInvoked(#selector(viewDidLoad))
            .map { _ in AlbumDetailReactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        Observable.just(reactor.currentState.album)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] album in
                self?.configure(with: album)
            }
            .disposed(by: disposeBag)

        reactor.state.map { $0.tracks }
            .distinctUntilChanged { lhs, rhs in
                lhs.map { $0.id } == rhs.map { $0.id }
            }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] tracks in
                self?.rootView.updateTracks(tracks)
            }
            .disposed(by: disposeBag)

        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] isLoading in
                self?.rootView.updateLoading(isLoading)
            }
            .disposed(by: disposeBag)

        reactor.state.map { $0.errorMessage }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] message in
                self?.showError(message: message)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UI Helpers
private extension AlbumDetailViewController {
    func showError(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    func showTrackDetail(track: SpotifyAlbumTrack) {
        guard let album = reactor?.currentState.album else { return }
        let converted = SpotifyTrack(
            id: track.id,
            name: track.name,
            artists: track.artists,
            album: album,
            durationMs: track.durationMs,
            popularity: 0,
            previewUrl: track.previewUrl,
            uri: track.uri
        )
        coordinator?.showTrackDetail(track: converted)
    }
}
