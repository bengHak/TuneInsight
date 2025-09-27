import UIKit
import SnapKit
import Then
import Kingfisher
import DomainKit

final class PlaylistListCell: UITableViewCell {
    static let identifier = "PlaylistListCell"

    // MARK: - UI Components

    private let playlistImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .secondarySystemBackground
    }

    private let placeholderImageView = UIImageView().then {
        $0.image = UIImage(systemName: "music.note.list")
        $0.tintColor = .tertiaryLabel
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }

    private let nameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .label
    }

    private let detailLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.textColor = .secondaryLabel
    }

    private let publicBadge = UILabel().then {
        $0.text = "공개"
        $0.font = .systemFont(ofSize: 11, weight: .medium)
        $0.textColor = .systemGreen
        $0.backgroundColor = .systemGreen.withAlphaComponent(0.15)
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.textAlignment = .center
        $0.isHidden = true
    }

    private let privateBadge = UILabel().then {
        $0.text = "비공개"
        $0.font = .systemFont(ofSize: 11, weight: .medium)
        $0.textColor = .systemGray
        $0.backgroundColor = .systemGray.withAlphaComponent(0.15)
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.textAlignment = .center
        $0.isHidden = true
    }

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        contentView.addSubview(playlistImageView)
        playlistImageView.addSubview(placeholderImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(publicBadge)
        contentView.addSubview(privateBadge)

        playlistImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(56)
        }

        placeholderImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(28)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(playlistImageView.snp.trailing).offset(12)
            make.top.equalTo(playlistImageView.snp.top).offset(4)
            make.trailing.lessThanOrEqualToSuperview().offset(-100)
        }

        detailLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.trailing.lessThanOrEqualToSuperview().offset(-100)
        }

        publicBadge.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(44)
            make.height.equalTo(20)
        }

        privateBadge.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(52)
            make.height.equalTo(20)
        }
    }

    // MARK: - Configure

    func configure(with playlist: Playlist) {
        nameLabel.text = playlist.name

        let trackText = playlist.trackCount == 1 ? "트랙" : "트랙"
        detailLabel.text = "\(playlist.owner.displayName) • \(playlist.trackCount)\(trackText)"

        // Set image
        if let imageUrl = playlist.imageUrl, let url = URL(string: imageUrl) {
            placeholderImageView.isHidden = true
            playlistImageView.kf.setImage(
                with: url,
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        } else {
            placeholderImageView.isHidden = false
            playlistImageView.image = nil
        }

        // Set badges
        if playlist.isPublic {
            publicBadge.isHidden = false
            privateBadge.isHidden = true
        } else {
            publicBadge.isHidden = true
            privateBadge.isHidden = false
        }

        // Collaborative badge could be added here if needed
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        playlistImageView.kf.cancelDownloadTask()
        playlistImageView.image = nil
        placeholderImageView.isHidden = true
        nameLabel.text = nil
        detailLabel.text = nil
        publicBadge.isHidden = true
        privateBadge.isHidden = true
    }
}