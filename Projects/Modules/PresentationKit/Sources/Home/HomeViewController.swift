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
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let refreshControl = UIRefreshControl()
    
    // 현재 재생 정보 섹션
    private let currentPlaybackContainerView = UIView().then {
        $0.backgroundColor = .secondarySystemBackground
        $0.layer.cornerRadius = 16
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.1
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 4
    }
    
    private let albumImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.backgroundColor = .systemGray5
    }
    
    private let trackNameLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .headline)
        $0.textColor = .label
        $0.numberOfLines = 2
    }
    
    private let artistNameLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .subheadline)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 1
    }
    
    private let albumNameLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .caption1)
        $0.textColor = .tertiaryLabel
        $0.numberOfLines = 1
    }
    
    private let controlsStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 20
    }
    
    private let previousButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        $0.tintColor = .label
        $0.titleLabel?.font = .preferredFont(forTextStyle: .title2)
    }
    
    private let playPauseButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "play.fill"), for: .normal)
        $0.tintColor = .label
        $0.titleLabel?.font = .preferredFont(forTextStyle: .title1)
    }
    
    private let nextButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        $0.tintColor = .label
        $0.titleLabel?.font = .preferredFont(forTextStyle: .title2)
    }
    
    private let progressView = UIProgressView().then {
        $0.progressTintColor = .systemGreen
        $0.trackTintColor = .systemGray4
    }
    
    private let progressLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .caption2)
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
    }
    
    // 최근 재생 섹션
    private let recentTracksLabel = UILabel().then {
        $0.text = "최근 재생"
        $0.font = .preferredFont(forTextStyle: .title2)
        $0.textColor = .label
    }
    
    private let recentTracksTableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.isScrollEnabled = false
        $0.register(RecentTrackCell.self, forCellReuseIdentifier: RecentTrackCell.identifier)
    }
    
    // 에러 표시
    private let errorLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .body)
        $0.textColor = .systemRed
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.isHidden = true
    }

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
        
        setupScrollView()
        setupCurrentPlaybackSection()
        setupRecentTracksSection()
        setupConstraints()
        setupControls()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.refreshControl = refreshControl
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    private func setupCurrentPlaybackSection() {
        contentView.addSubview(currentPlaybackContainerView)
        contentView.addSubview(errorLabel)
        
        [albumImageView, trackNameLabel, artistNameLabel, albumNameLabel, 
         controlsStackView, progressView, progressLabel].forEach {
            currentPlaybackContainerView.addSubview($0)
        }
        
        [previousButton, playPauseButton, nextButton].forEach {
            controlsStackView.addArrangedSubview($0)
        }
    }
    
    private func setupRecentTracksSection() {
        contentView.addSubview(recentTracksLabel)
        contentView.addSubview(recentTracksTableView)
    }
    
    private func setupConstraints() {
        errorLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        currentPlaybackContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        albumImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(200)
        }
        
        trackNameLabel.snp.makeConstraints { make in
            make.top.equalTo(albumImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        artistNameLabel.snp.makeConstraints { make in
            make.top.equalTo(trackNameLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        albumNameLabel.snp.makeConstraints { make in
            make.top.equalTo(artistNameLabel.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        controlsStackView.snp.makeConstraints { make in
            make.top.equalTo(albumNameLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalTo(180)
            make.height.equalTo(50)
        }
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(controlsStackView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(4)
        }
        
        progressLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }
        
        recentTracksLabel.snp.makeConstraints { make in
            make.top.equalTo(currentPlaybackContainerView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        recentTracksTableView.snp.makeConstraints { make in
            make.top.equalTo(recentTracksLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(300) // 5개 셀 * 60 높이
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
    private func setupControls() {
        [previousButton, playPauseButton, nextButton].forEach { button in
            button.snp.makeConstraints { make in
                make.size.equalTo(50)
            }
        }
    }

    // MARK: - Reactor Binding

    public func bind(reactor: HomeReactor) {
        bindActions(reactor)
        bindState(reactor)
    }
    
    private func bindActions(_ reactor: HomeReactor) {
        // View Did Load
        rx.methodInvoked(#selector(viewDidLoad))
            .map { _ in Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Refresh Control
        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Playback Controls
        playPauseButton.rx.tap
            .map { Reactor.Action.playPause }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .map { Reactor.Action.nextTrack }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        previousButton.rx.tap
            .map { Reactor.Action.previousTrack }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: HomeReactor) {
        // Loading State
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        // Current Playback
        reactor.state.map { $0.currentPlayback }
            .distinctUntilChanged { $0?.track?.id == $1?.track?.id && $0?.isPlaying == $1?.isPlaying }
            .subscribe(onNext: { [weak self] playback in
                self?.updateCurrentPlayback(playback)
            })
            .disposed(by: disposeBag)
        
        // Recent Tracks
        reactor.state.map { $0.recentTracks }
            .distinctUntilChanged { $0.count == $1.count && $0.first?.track.id == $1.first?.track.id }
            .bind(to: recentTracksTableView.rx.items(
                cellIdentifier: RecentTrackCell.identifier,
                cellType: RecentTrackCell.self
            )) { index, track, cell in
                cell.configure(with: track)
            }
            .disposed(by: disposeBag)
        
        // Error Message
        reactor.state.map { $0.errorMessage }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] error in
                self?.updateErrorState(error)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Update UI
    
    private func updateCurrentPlayback(_ playback: CurrentPlayback?) {
        guard let playback = playback, playback.isActive else {
            currentPlaybackContainerView.isHidden = true
            return
        }
        
        currentPlaybackContainerView.isHidden = false
        
        trackNameLabel.text = playback.trackName
        artistNameLabel.text = playback.artistName
        albumNameLabel.text = playback.albumName
        
        // 재생/일시정지 버튼 상태 업데이트
        let imageName = playback.isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        // 진행률 업데이트
        progressView.progress = playback.progressPercentage
        progressLabel.text = playback.formattedProgress
        
        // 앨범 이미지 로드 (여기서는 간단히 처리, 실제로는 SDWebImage 등 사용)
        if let imageUrl = playback.albumImageUrl {
            loadAlbumImage(from: imageUrl)
        }
    }
    
    private func updateErrorState(_ errorMessage: String?) {
        if let error = errorMessage {
            errorLabel.text = error
            errorLabel.isHidden = false
            currentPlaybackContainerView.isHidden = true
        } else {
            errorLabel.isHidden = true
        }
    }
    
    private func loadAlbumImage(from urlString: String) {
        // 실제 구현에서는 SDWebImage나 Kingfisher 등을 사용
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.albumImageView.image = image
            }
        }.resume()
    }
}

// MARK: - Recent Track Cell

private class RecentTrackCell: UITableViewCell {
    
    private let trackImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 6
        $0.clipsToBounds = true
        $0.backgroundColor = .systemGray5
    }
    
    private let trackNameLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .subheadline)
        $0.textColor = .label
        $0.numberOfLines = 1
    }
    
    private let artistNameLabel = UILabel().then {
        $0.font = .preferredFont(forTextStyle: .caption1)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 1
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static let identifier = "\(RecentTrackCell.self)"
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(trackImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        
        trackImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(50)
        }
        
        trackNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(trackImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(20)
            make.top.equalTo(trackImageView.snp.top).offset(4)
        }
        
        artistNameLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(trackNameLabel)
            make.bottom.equalTo(trackImageView.snp.bottom).inset(4)
        }
    }
    
    func configure(with recentTrack: RecentTrack) {
        trackNameLabel.text = recentTrack.track.name
        artistNameLabel.text = recentTrack.track.primaryArtist
        
        if let imageUrl = recentTrack.track.albumImageUrl {
            loadTrackImage(from: imageUrl)
        }
    }
    
    private func loadTrackImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.trackImageView.image = image
            }
        }.resume()
    }
}
