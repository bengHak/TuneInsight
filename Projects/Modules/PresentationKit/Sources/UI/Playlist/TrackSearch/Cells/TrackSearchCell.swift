import UIKit
import SnapKit
import Then
import Kingfisher
import DomainKit

public final class TrackSearchCell: UITableViewCell {
    public static let identifier = "TrackSearchCell"

    // MARK: - UI Components

    private let checkboxButton = UIButton(type: .custom).then {
        $0.setImage(UIImage(systemName: "circle"), for: .normal)
        $0.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        $0.tintColor = .systemBlue
        $0.contentMode = .scaleAspectFit
    }

    private let trackImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 4
        $0.backgroundColor = .secondarySystemBackground
    }

    private let trackNameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .label
        $0.numberOfLines = 1
    }

    private let artistNameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 1
    }

    private let albumNameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textColor = .tertiaryLabel
        $0.numberOfLines = 1
    }

    private let durationLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .tertiaryLabel
        $0.textAlignment = .right
    }

    private let popularityLabel = UILabel().then {
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

    private let explicitBadge = UILabel().then {
        $0.text = "E"
        $0.font = .systemFont(ofSize: 10, weight: .bold)
        $0.textColor = .white
        $0.backgroundColor = .systemGray
        $0.textAlignment = .center
        $0.layer.cornerRadius = 2
        $0.clipsToBounds = true
        $0.isHidden = true
    }

    // MARK: - Properties

    private var track: SearchTrackResult?
    public var onSelectionChanged: ((SearchTrackResult, Bool) -> Void)?

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        selectionStyle = .none

        contentView.addSubview(checkboxButton)
        contentView.addSubview(trackImageView)
        contentView.addSubview(infoStackView)
        contentView.addSubview(rightStackView)
        contentView.addSubview(explicitBadge)

        infoStackView.addArrangedSubview(trackNameLabel)
        infoStackView.addArrangedSubview(artistNameLabel)
        infoStackView.addArrangedSubview(albumNameLabel)

        rightStackView.addArrangedSubview(durationLabel)
        rightStackView.addArrangedSubview(popularityLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        checkboxButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }

        trackImageView.snp.makeConstraints { make in
            make.leading.equalTo(checkboxButton.snp.trailing).offset(12)
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

        explicitBadge.snp.makeConstraints { make in
            make.leading.equalTo(trackNameLabel.snp.trailing).offset(4)
            make.centerY.equalTo(trackNameLabel)
            make.size.equalTo(CGSize(width: 14, height: 14))
        }

        // Content priority settings
        trackNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        artistNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        albumNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        trackNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        artistNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        albumNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private func setupActions() {
        checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(tapGesture)
    }

    // MARK: - Actions

    @objc private func checkboxTapped() {
        guard let track = track else { return }

        checkboxButton.isSelected.toggle()
        onSelectionChanged?(track, checkboxButton.isSelected)

        updateSelectionAppearance()
    }

    @objc private func cellTapped() {
        checkboxTapped()
    }

    // MARK: - Configure

    public func configure(with track: SearchTrackResult, isSelected: Bool) {
        self.track = track

        trackNameLabel.text = track.name
        artistNameLabel.text = track.artistsText
        albumNameLabel.text = track.album
        durationLabel.text = track.formattedDuration

        if let popularity = track.popularity {
            popularityLabel.text = "\(popularity)%"
            popularityLabel.isHidden = false
        } else {
            popularityLabel.isHidden = true
        }

        explicitBadge.isHidden = !track.explicit

        checkboxButton.isSelected = isSelected
        updateSelectionAppearance()

        if let imageUrl = track.albumImageUrl {
            trackImageView.kf.setImage(with: URL(string: imageUrl))
        } else {
            trackImageView.image = UIImage(systemName: "music.note")
            trackImageView.tintColor = .secondaryLabel
        }
    }

    private func updateSelectionAppearance() {
        let isSelected = checkboxButton.isSelected

        // Visual feedback for selection
        UIView.animate(withDuration: 0.2) {
            self.contentView.backgroundColor = isSelected ?
                UIColor.systemBlue.withAlphaComponent(0.1) :
                UIColor.clear

            self.trackNameLabel.textColor = isSelected ? .systemBlue : .label
        }
    }

    override public func prepareForReuse() {
        super.prepareForReuse()

        trackImageView.kf.cancelDownloadTask()
        trackImageView.image = nil
        checkboxButton.isSelected = false
        contentView.backgroundColor = .clear
        trackNameLabel.textColor = .label
        explicitBadge.isHidden = true
        popularityLabel.isHidden = true
        track = nil
        onSelectionChanged = nil
    }
}