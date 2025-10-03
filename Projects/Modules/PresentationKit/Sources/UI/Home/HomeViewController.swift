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
    
    private lazy var topPlayedArtistView = HomeTopPlayedArtistView()
    
    private lazy var recentTracksView = RecentTracksView()
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
    }
    
    private let contentView = UIView()
    private let gradientLayer = CAGradientLayer()
    
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
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reactor?.action.onNext(.startAutoRefresh)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reactor?.action.onNext(.stopAutoRefresh)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .white

        configureBackgroundGradient()
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(playerView)
        contentView.addSubview(topPlayedArtistView)
        contentView.addSubview(recentTracksView)
        recentTracksView.delegate = self
        topPlayedArtistView.delegate = self
        scrollView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        setupConstraints()
    }
    
    private func configureBackgroundGradient() {
        gradientLayer.colors = [
            CustomColor.systemGreen.cgColor,
            CustomColor.white.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        if gradientLayer.superlayer == nil {
            view.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        playerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        recentTracksView.snp.makeConstraints { make in
            make.top.equalTo(playerView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
        }

        topPlayedArtistView.snp.makeConstraints { make in
            make.top.equalTo(recentTracksView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(topPlayedArtistView.snp.bottom)
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
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] playbackDisplay in
                self?.updatePlayerView(with: playbackDisplay)
            }.disposed(by: disposeBag)
        
        reactor.state.map { $0.recentTracks }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] recentTracks in
                self?.recentTracksView.updateTracks(recentTracks)
            }.disposed(by: disposeBag)
        
        reactor.state.map { $0.topArtists }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] topArtists in
                self?.topPlayedArtistView.updateArtists(topArtists)
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
    
    private func updatePlayerView(with playbackDisplay: PlaybackDisplay?) {
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

// MARK: - RecentTracksViewDelegate

extension HomeViewController: RecentTracksViewDelegate {
    public func recentTracksView(_ view: RecentTracksView, didSelect track: RecentTrack) {
        coordinator?.showTrackDetail(track.track)
    }
}

// MARK: - HomeTopPlayedArtistViewDelegate
extension HomeViewController: HomeTopPlayedArtistViewDelegate {
    public func homeTopPlayedArtistView(_ view: HomeTopPlayedArtistView, didSelect artist: SpotifyArtist) {
        coordinator?.showArtistDetail(artist)
    }
}
