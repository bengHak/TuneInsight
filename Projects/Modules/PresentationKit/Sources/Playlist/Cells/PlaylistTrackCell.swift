import UIKit
import SnapKit
import Then
import Kingfisher
import DomainKit

public final class PlaylistTrackCell: UITableViewCell {
    public static let identifier = "PlaylistTrackCell"

    // MARK: - UI Components

    private let trackImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 4
        $0.backgroundColor = .secondarySystemBackground
    }

    private let trackNameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .label
    }

    private let artistNameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .secondaryLabel
    }

    private let albumNameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textColor = .tertiaryLabel
    }

    private let durationLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .tertiaryLabel
        $0.textAlignment = .right
    }

    private let addedDateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textColor = .tertiaryLabel
        $0.textAlignment = .right
    }

    private let infoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 2
        $0.alignment = .leading
    }

    private let rightStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 2
        $0.alignment = .trailing
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
        selectionStyle = .none

        contentView.addSubview(trackImageView)
        contentView.addSubview(infoStackView)
        contentView.addSubview(rightStackView)

        infoStackView.addArrangedSubview(trackNameLabel)
        infoStackView.addArrangedSubview(artistNameLabel)
        infoStackView.addArrangedSubview(albumNameLabel)

        rightStackView.addArrangedSubview(durationLabel)
        rightStackView.addArrangedSubview(addedDateLabel)

        trackImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(48)
        }

        infoStackView.snp.makeConstraints { make in
            make.leading.equalTo(trackImageView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(rightStackView.snp.leading).offset(-12)
        }

        rightStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualTo(80)
        }

        trackNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        artistNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        albumNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }

    // MARK: - Configure

    public func configure(with playlistTrack: PlaylistTrack) {
        trackNameLabel.text = playlistTrack.name
        artistNameLabel.text = playlistTrack.artistsText
        albumNameLabel.text = playlistTrack.album

        durationLabel.text = playlistTrack.formattedDuration
        if let addedAt = playlistTrack.addedAt {
            addedDateLabel.text = formatDate(addedAt)
        } else {
            addedDateLabel.text = ""
        }

        if let imageUrl = playlistTrack.albumImageUrl {
            trackImageView.kf.setImage(with: URL(string: imageUrl))
        } else {
            trackImageView.image = UIImage(systemName: "music.note")
            trackImageView.tintColor = .secondaryLabel
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        trackImageView.kf.cancelDownloadTask()
        trackImageView.image = nil
    }
}