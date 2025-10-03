import UIKit
import DomainKit
import ReactorKit
import RxSwift

public final class ArtistDetailViewController: UIViewController, ReactorKit.View {
    public var disposeBag = DisposeBag()
    private let rootView = ArtistDetailView()
    weak var coordinator: ArtistDetailCoordinator?

    // MARK: - Init
    public init(reactor: ArtistDetailReactor) {
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

    // MARK: - Setup
    private func setupUI() {
        title = "아티스트 상세"
        view.addSubview(rootView)
        rootView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        rootView.didSelectAlbum = { [weak self] album in
            self?.showAlbumDetail(album: album)
        }

        rootView.didSelectTrack = { [weak self] track in
            self?.showTrackDetail(track: track)
        }

        rootView.didTapOpenInSpotify = { [weak self] uri in
            self?.openInSpotify(uri: uri)
        }
    }

    // MARK: - Configure
    private func configure(with artist: SpotifyArtist) {
        rootView.configure(with: artist)
    }

    // MARK: - Actions
    private func showAlbumDetail(album: SpotifyAlbum) {
        coordinator?.showAlbumDetail(album: album)
    }

    private func showTrackDetail(track: SpotifyTrack) {
        coordinator?.showTrackDetail(track: track)
    }

    private func openInSpotify(uri: String) {
        let potentialURLs = resolveSpotifyURLs(from: uri)
        let application = UIApplication.shared

        for url in potentialURLs {
            if application.canOpenURL(url) {
                application.open(url, options: [:], completionHandler: nil)
                return
            }
        }

        showUnableToOpenAlert()
    }

    private func resolveSpotifyURLs(from uri: String) -> [URL] {
        var urls: [URL] = []
        if let directURL = URL(string: uri) {
            urls.append(directURL)
        }

        if uri.hasPrefix("spotify:") {
            let components = uri.split(separator: ":")
            if components.count >= 3 {
                let type = components[1]
                let identifier = components[2]
                let webURLString = "https://open.spotify.com/\(type)/\(identifier)"
                if let webURL = URL(string: webURLString) {
                    urls.append(webURL)
                }
            }
        }

        return urls
    }

    private func showUnableToOpenAlert() {
        let alert = UIAlertController(
            title: "Spotify 열기 실패",
            message: "Spotify 링크를 열 수 없습니다. 앱이나 브라우저 설정을 확인해주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Bindings
public extension ArtistDetailViewController {
    func bind(reactor: ArtistDetailReactor) {
        // Lifecycle
        rx.methodInvoked(#selector(viewDidLoad))
            .map { _ in ArtistDetailReactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Static info from initial artist
        Observable.just(reactor.currentState.artist)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] artist in
                self?.configure(with: artist)
            }
            .disposed(by: disposeBag)

        // Albums
        reactor.state.map { $0.albums }
            .distinctUntilChanged { $0.map{ $0.id } == $1.map{ $0.id } }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] albums in
                self?.rootView.updateAlbums(albums)
            }
            .disposed(by: disposeBag)

        // Top tracks
        reactor.state.map { $0.topTracks }
            .distinctUntilChanged { $0.map{ $0.id } == $1.map{ $0.id } }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] tracks in
                self?.rootView.updateTopTracks(tracks)
            }
            .disposed(by: disposeBag)

        // Error
        reactor.state.map { $0.errorMessage }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] message in
                self?.showError(message: message)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UI Update Helpers
private extension ArtistDetailViewController {
    // UI 업데이트는 ArtistDetailView로 이동

    func showError(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
