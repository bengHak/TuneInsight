import UIKit
import SnapKit
import Kingfisher

public final class RecentTrackCell: UITableViewCell {
    public struct ViewModel {
        public let titleText: String
        public let artistText: String
        public let albumText: String?
        public let playedAtText: String?
        public let durationText: String?
        public let rankText: String?
        public let artworkURL: URL?
        public let placeholderSystemName: String

        public init(
            titleText: String,
            artistText: String,
            albumText: String? = nil,
            playedAtText: String? = nil,
            durationText: String? = nil,
            rankText: String? = nil,
            artworkURL: URL? = nil,
            placeholderSystemName: String = "music.note"
        ) {
            self.titleText = titleText
            self.artistText = artistText
            self.albumText = albumText
            self.playedAtText = playedAtText
            self.durationText = durationText
            self.rankText = rankText
            self.artworkURL = artworkURL
            self.placeholderSystemName = placeholderSystemName
        }
    }

    public static let identifier = String(describing: RecentTrackCell.self)
    public static let cellHeight: CGFloat = 96

    // MARK: - UI

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = CustomColor.white80
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let artworkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray5
        return imageView
    }()

    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()

    private let titleStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        return stack
    }()

    private let textStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 4
        return stack
    }()

    private let artistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    private let albumLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 1
        return label
    }()

    private let playedAtLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .tertiaryLabel
        label.textAlignment = .right
        label.numberOfLines = 1
        return label
    }()

    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .tertiaryLabel
        label.textAlignment = .right
        label.numberOfLines = 1
        return label
    }()

    private let infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .trailing
        stack.spacing = 2
        return stack
    }()

    // MARK: - Init

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    private func setupLayout() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(containerView)
        containerView.addSubview(artworkImageView)
        containerView.addSubview(textStackView)
        containerView.addSubview(infoStackView)

        titleStackView.addArrangedSubview(rankLabel)
        titleStackView.addArrangedSubview(titleLabel)

        textStackView.addArrangedSubview(titleStackView)
        textStackView.addArrangedSubview(artistLabel)
        textStackView.addArrangedSubview(albumLabel)
        
        infoStackView.addArrangedSubview(playedAtLabel)
        infoStackView.addArrangedSubview(durationLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12))
        }

        artworkImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(6)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }

        infoStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        textStackView.snp.makeConstraints { make in
            make.top.equalTo(artworkImageView.snp.top)
            make.leading.equalTo(artworkImageView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(infoStackView.snp.leading).offset(-8)
            make.bottom.equalToSuperview().inset(12)
        }

        rankLabel.isHidden = true
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        artworkImageView.kf.cancelDownloadTask()
        artworkImageView.image = nil
        artworkImageView.tintColor = nil
        titleLabel.text = nil
        artistLabel.text = nil
        albumLabel.text = nil
        playedAtLabel.text = nil
        durationLabel.text = nil
        rankLabel.text = nil
        rankLabel.isHidden = true
        playedAtLabel.isHidden = false
        durationLabel.isHidden = false
        albumLabel.isHidden = false
    }

    public func configure(with viewModel: ViewModel) {
        titleLabel.text = viewModel.titleText
        artistLabel.text = viewModel.artistText

        if let albumText = viewModel.albumText, !albumText.isEmpty {
            albumLabel.text = albumText
            albumLabel.isHidden = false
        } else {
            albumLabel.text = nil
            albumLabel.isHidden = true
        }

        if let playedAtText = viewModel.playedAtText, !playedAtText.isEmpty {
            playedAtLabel.text = playedAtText
            playedAtLabel.isHidden = false
        } else {
            playedAtLabel.text = nil
            playedAtLabel.isHidden = true
        }

        if let durationText = viewModel.durationText, !durationText.isEmpty {
            durationLabel.text = durationText
            durationLabel.isHidden = false
        } else {
            durationLabel.text = nil
            durationLabel.isHidden = true
        }

        if let rankText = viewModel.rankText, !rankText.isEmpty {
            rankLabel.text = rankText
            rankLabel.isHidden = false
        } else {
            rankLabel.text = nil
            rankLabel.isHidden = true
        }

        if let artworkURL = viewModel.artworkURL {
            artworkImageView.kf.setImage(with: artworkURL)
            artworkImageView.tintColor = nil
        } else {
            let placeholder = UIImage(systemName: viewModel.placeholderSystemName)
            artworkImageView.image = placeholder
            artworkImageView.tintColor = .secondaryLabel
        }
    }
}
