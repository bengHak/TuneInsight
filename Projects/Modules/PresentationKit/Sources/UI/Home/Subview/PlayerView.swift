import UIKit
import SnapKit
import Then
import DomainKit
import RxSwift
import RxCocoa
import Kingfisher
import FoundationKit

public protocol PlayerViewDelegate: AnyObject {
    func playerView(_ playerView: PlayerView, didTapPlayPause isPlaying: Bool)
    func playerView(_ playerView: PlayerView, didTapNext: Void)
    func playerView(_ playerView: PlayerView, didTapPrevious: Void)
    func playerView(_ playerView: PlayerView, didSeekTo positionMs: Int)
}

public final class PlayerView: UIView {
    
    
    // MARK: - Properties
    
    public weak var delegate: PlayerViewDelegate?
    private var disposeBag = DisposeBag()
    private var playbackDisplay: PlaybackDisplay?
    private var isPlaying: Bool = false
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = CustomColor.surfaceElevated
        $0.layer.cornerRadius = 16
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.25
        $0.layer.shadowOffset = CGSize(width: 0, height: 8)
        $0.layer.shadowRadius = 18
        $0.layer.borderWidth = 1
        $0.layer.borderColor = CustomColor.border.cgColor
    }
    
    private let albumImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = CustomColor.border.cgColor
        $0.backgroundColor = CustomColor.surface
        $0.image = UIImage(systemName: "music.note")
        $0.tintColor = CustomColor.secondaryText
    }
    
    private let trackInfoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.alignment = .leading
        $0.distribution = .fill
    }
    
    private let trackNameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = CustomColor.primaryText
        $0.numberOfLines = 1
        $0.text = "player.notPlaying".localized()
        $0.accessibilityIdentifier = "player_track_name"
    }
    
    private let artistNameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = CustomColor.secondaryText
        $0.numberOfLines = 1
        $0.text = ""
        $0.accessibilityIdentifier = "player_artist_name"
    }
    
    private let controlStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 16
        $0.alignment = .center
        $0.distribution = .fill
    }
    
    private let previousButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        $0.tintColor = CustomColor.primaryText
        $0.isEnabled = false
        $0.accessibilityLabel = "player.previousTrackAccessibility".localized()
        $0.accessibilityIdentifier = "player_previous_button"
    }
    
    private let playPauseButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "play.fill"), for: .normal)
        $0.tintColor = CustomColor.primaryText
        $0.isEnabled = false
        $0.accessibilityLabel = "player.play".localized()
        $0.accessibilityIdentifier = "player_play_pause_button"
    }
    
    private let nextButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        $0.tintColor = CustomColor.primaryText
        $0.isEnabled = false
        $0.accessibilityLabel = "player.nextTrackAccessibility".localized()
        $0.accessibilityIdentifier = "player_next_button"
    }
    
    private let progressStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .fill
        $0.distribution = .fill
    }
    
    private let progressView = UIProgressView(progressViewStyle: .default).then {
        $0.progressTintColor = CustomColor.accent
        $0.trackTintColor = CustomColor.overlay
        $0.progress = 0.0
    }
    
    private let timeStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
        $0.distribution = .equalSpacing
    }
    
    private let currentTimeLabel = UILabel().then {
        $0.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        $0.textColor = CustomColor.secondaryText
        $0.text = "0:00"
        $0.accessibilityIdentifier = "player_current_time"
    }
    
    private let totalTimeLabel = UILabel().then {
        $0.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        $0.textColor = CustomColor.secondaryText
        $0.text = "0:00"
        $0.accessibilityIdentifier = "player_total_time"
    }
    
    private let emptyStateLabel = UILabel().then {
        $0.text = "player.notPlaying".localized()
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = CustomColor.secondaryText
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.isHidden = false
    }
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupBindings()
    }
    
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(containerView)
        
        containerView.addSubview(albumImageView)
        containerView.addSubview(trackInfoStackView)
        containerView.addSubview(controlStackView)
        containerView.addSubview(progressStackView)
        containerView.addSubview(emptyStateLabel)
        
        trackInfoStackView.addArrangedSubview(trackNameLabel)
        trackInfoStackView.addArrangedSubview(artistNameLabel)
        
        controlStackView.addArrangedSubview(previousButton)
        controlStackView.addArrangedSubview(playPauseButton)
        controlStackView.addArrangedSubview(nextButton)
        
        progressStackView.addArrangedSubview(progressView)
        progressStackView.addArrangedSubview(timeStackView)
        
        timeStackView.addArrangedSubview(currentTimeLabel)
        timeStackView.addArrangedSubview(UIView()) // spacer
        timeStackView.addArrangedSubview(totalTimeLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        albumImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
            make.width.height.equalTo(60)
        }
        
        trackInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(albumImageView.snp.top)
            make.leading.equalTo(albumImageView.snp.trailing).offset(12)
            make.trailing.equalTo(controlStackView.snp.leading).offset(-12)
        }
        
        controlStackView.snp.makeConstraints { make in
            make.top.equalTo(albumImageView.snp.top)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        progressStackView.snp.makeConstraints { make in
            make.top.equalTo(albumImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
        
        [previousButton, playPauseButton, nextButton].forEach { button in
            button.snp.makeConstraints { make in
                make.width.height.equalTo(44)
            }
        }
        
        progressView.snp.makeConstraints { make in
            make.height.equalTo(6)
        }
        
        emptyStateLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupBindings() {
        playPauseButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.delegate?.playerView(self, didTapPlayPause: self.isPlaying)
            }
            .disposed(by: disposeBag)
        
        previousButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.delegate?.playerView(self, didTapPrevious: ())
            }
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.delegate?.playerView(self, didTapNext: ())
            }
            .disposed(by: disposeBag)
        
        // Progress view tap gesture for seeking
        let tapGesture = UITapGestureRecognizer()
        progressView.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .bind { [weak self] gesture in
                guard let self = self,
                      let playbackDisplay = self.playbackDisplay,
                      let track = playbackDisplay.track else { return }
                
                let location = gesture.location(in: self.progressView)
                let progress = Float(location.x / self.progressView.bounds.width)
                let clampedProgress = max(0, min(1, progress))
                let positionMs = Int(clampedProgress * Float(track.durationMs))
                
                self.delegate?.playerView(self, didSeekTo: positionMs)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Public Methods
    
    public func updatePlaybackDisplay(_ display: PlaybackDisplay?) {
        playbackDisplay = display
        
        guard let display,
              let track = display.track else {
            updateToNoTrackState()
            return
        }
        
        updateTrackInfo(track)
        updatePlaybackState(display.isPlaying)
        updateControlButtons(enabled: true)
        
        updateProgress(display)
    }
    
    private func updateProgress(_ display: PlaybackDisplay) {
        progressView.progress = display.progressPercentage
        currentTimeLabel.text = display.formattedProgress
        totalTimeLabel.text = display.formattedDuration
    }
    
    // MARK: - Private Methods
    
    private func updateToNoTrackState() {
        // 모든 기존 UI 요소들 숨김
        albumImageView.isHidden = true
        trackInfoStackView.isHidden = true
        controlStackView.isHidden = true
        progressStackView.isHidden = true
        
        // emptyStateLabel만 표시
        emptyStateLabel.isHidden = false
        
        // 기존 데이터 초기화
        albumImageView.kf.cancelDownloadTask()
        albumImageView.image = UIImage(systemName: "music.note")
        albumImageView.tintColor = CustomColor.secondaryText
        progressView.progress = 0.0
        currentTimeLabel.text = "0:00"
        totalTimeLabel.text = "0:00"
        
        updatePlaybackState(false)
        updateControlButtons(enabled: false)
    }
    
    private func updateTrackInfo(_ track: SpotifyTrack) {
        // emptyStateLabel 숨김
        emptyStateLabel.isHidden = true
        
        // 모든 기존 UI 요소들 표시
        albumImageView.isHidden = false
        trackInfoStackView.isHidden = false
        controlStackView.isHidden = false
        progressStackView.isHidden = false
        
        // 트랙 정보 업데이트
        trackNameLabel.text = track.name
        artistNameLabel.text = track.primaryArtist
        totalTimeLabel.text = track.durationFormatted
        
        // 앨범 아트 로드
        if let imageUrlString = track.albumImageUrl,
           let imageUrl = URL(string: imageUrlString) {
            albumImageView.kf.setImage(
                with: imageUrl,
                placeholder: UIImage(systemName: "music.note"),
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ]
            )
            albumImageView.tintColor = nil
        } else {
            albumImageView.image = UIImage(systemName: "music.note")
            albumImageView.tintColor = CustomColor.secondaryText
        }
    }
    
    
    private func updatePlaybackState(_ isPlaying: Bool) {
        self.isPlaying = isPlaying

        if playbackDisplay?.track == nil {
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playPauseButton.accessibilityLabel = "player.play".localized()
        } else if isPlaying {
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            playPauseButton.accessibilityLabel = "player.pause".localized()
        } else {
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playPauseButton.accessibilityLabel = "player.play".localized()
        }

        updatePlayPauseTint()
    }

    private func updateControlButtons(enabled: Bool) {
        let tint = enabled ? CustomColor.primaryText : CustomColor.tertiaryText

        [previousButton, nextButton].forEach { button in
            button.isEnabled = enabled
            button.tintColor = tint
            button.alpha = enabled ? 1.0 : 0.4
        }

        playPauseButton.isEnabled = enabled
        playPauseButton.alpha = enabled ? 1.0 : 0.4

        if enabled {
            updatePlayPauseTint()
        } else {
            playPauseButton.tintColor = CustomColor.tertiaryText
        }
    }

    private func updatePlayPauseTint() {
        guard playbackDisplay?.track != nil else {
            playPauseButton.tintColor = CustomColor.tertiaryText
            return
        }

        playPauseButton.tintColor = isPlaying ? CustomColor.accent : CustomColor.primaryText
    }
    
}

// MARK: - Accessibility

extension PlayerView {
    public override var isAccessibilityElement: Bool {
        get { false }
        set { }
    }
    
    public override var accessibilityElements: [Any]? {
        get {
            return [
                trackNameLabel,
                artistNameLabel,
                previousButton,
                playPauseButton,
                nextButton,
                progressView,
                currentTimeLabel,
                totalTimeLabel
            ]
        }
        set { }
    }
}
