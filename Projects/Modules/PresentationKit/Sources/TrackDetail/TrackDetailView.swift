import UIKit
import Then
import SnapKit
import Kingfisher
import DomainKit

final class TrackDetailView: UIView {
    // MARK: - UI
    private let scrollView = UIScrollView().then {
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = false
    }

    private let contentView = UIView()

    private let albumImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .secondarySystemBackground
        $0.accessibilityIdentifier = "trackdetail_album_image"
    }

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 22, weight: .bold)
        $0.textColor = .label
        $0.numberOfLines = 2
        $0.accessibilityIdentifier = "trackdetail_title"
    }

    private let artistLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 1
        $0.accessibilityIdentifier = "trackdetail_artist"
    }

    private let albumLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .tertiaryLabel
        $0.numberOfLines = 1
        $0.accessibilityIdentifier = "trackdetail_album"
    }

    private let infoStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 6
        $0.distribution = .fill
        $0.alignment = .fill
    }

    private let durationLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .secondaryLabel
        $0.accessibilityIdentifier = "trackdetail_duration"
    }

    private let popularityLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .secondaryLabel
        $0.accessibilityIdentifier = "trackdetail_popularity"
    }

    let addToQueueButton = UIButton(type: .system).then {
        $0.setTitle("대기열에 추가", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.tintColor = .white
        $0.backgroundColor = .systemGreen
        $0.layer.cornerRadius = 10
        $0.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        $0.accessibilityIdentifier = "trackdetail_add_to_queue"
    }

    let skipNextButton = UIButton(type: .system).then {
        $0.setTitle("바로 재생", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.tintColor = .white
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 10
        $0.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        $0.accessibilityIdentifier = "trackdetail_skip_next"
    }

    // 고정 플레이어 뷰 외부에서 주입받기 위한 컨테이너
    let playerContainerView = UIView().then {
        $0.backgroundColor = .clear
        $0.accessibilityIdentifier = "trackdetail_player_container"
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .systemBackground

        addSubview(scrollView)
        addSubview(playerContainerView)
        scrollView.addSubview(contentView)

        contentView.addSubview(albumImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(artistLabel)
        contentView.addSubview(albumLabel)
        contentView.addSubview(infoStack)
        contentView.addSubview(addToQueueButton)
        contentView.addSubview(skipNextButton)

        infoStack.addArrangedSubview(durationLabel)
        infoStack.addArrangedSubview(popularityLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        playerContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }

        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(playerContainerView.snp.top)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        albumImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(albumImageView.snp.width) // 정사각형
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(albumImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        artistLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalTo(titleLabel)
        }

        albumLabel.snp.makeConstraints { make in
            make.top.equalTo(artistLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(titleLabel)
        }

        infoStack.snp.makeConstraints { make in
            make.top.equalTo(albumLabel.snp.bottom).offset(12)
            make.leading.trailing.equalTo(titleLabel)
        }

        addToQueueButton.snp.makeConstraints { make in
            make.top.equalTo(infoStack.snp.bottom).offset(20)
            make.leading.trailing.equalTo(titleLabel)
        }

        skipNextButton.snp.makeConstraints { make in
            make.top.equalTo(addToQueueButton.snp.bottom).offset(12)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(24)
        }
    }

    // MARK: - Update
    func update(with track: SpotifyTrack) {
        titleLabel.text = track.name
        artistLabel.text = track.artistNames
        albumLabel.text = track.album.name
        durationLabel.text = "길이: \(track.durationFormatted)"
        popularityLabel.text = "인기도: \(track.popularity)"

        if let urlString = track.albumImageUrl, let url = URL(string: urlString) {
            albumImageView.kf.setImage(with: url)
        } else {
            albumImageView.image = nil
        }
    }
}
