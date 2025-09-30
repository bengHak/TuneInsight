import UIKit
import SnapKit
import DomainKit
import Kingfisher

public protocol RecentTracksViewDelegate: AnyObject {
    func recentTracksView(_ view: RecentTracksView, didSelect track: RecentTrack)
}

public final class RecentTracksView: UIView {
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "최근 재생된 트랙"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(RecentTrackCell.self, forCellReuseIdentifier: RecentTrackCell.identifier)
        tv.rowHeight = RecentTrackCell.cellHeight
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        return tv
    }()
    
    // MARK: - Properties
    
    private var tracks: [RecentTrack] = []
    public weak var delegate: RecentTracksViewDelegate?
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .white.withAlphaComponent(0.4)
        
        addSubview(titleLabel)
        addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        setupConstraints()
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }

        self.snp.makeConstraints { make in
            make.height.equalTo(76) // 초기 최소 높이 (타이틀만 있을 때)
        }
    }
    
    // MARK: - Public
    
    /// 최신 트랙 배열을 전달하면 테이블이 갱신됩니다.
    public func updateTracks(_ tracks: [RecentTrack]) {
        self.tracks = tracks
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            self?.updateHeight()
        }
    }

    private func updateHeight() {
        let calculatedHeight = getHeight()
        snp.updateConstraints { make in
            make.height.equalTo(calculatedHeight)
        }
    }

    public func getHeight() -> CGFloat {
        let titleHeight: CGFloat = 60 // 타이틀 + 패딩
        let tableHeight = CGFloat(tracks.count) * RecentTrackCell.cellHeight

        return titleHeight + tableHeight
    }
}

// MARK: - UITableViewDataSource

extension RecentTracksView: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: RecentTrackCell.identifier,
            for: indexPath
        ) as? RecentTrackCell else {
            assertionFailure("RecentTrackCell not registered")
            return UITableViewCell()
        }
        
        let track = tracks[indexPath.row]
        cell.configure(with: track)
        return cell
    }
}

// MARK: - RecentTrackCell

private final class RecentTrackCell: UITableViewCell {
    
    static let identifier = String(describing: RecentTrackCell.self)
    static let cellHeight: CGFloat = 80
    
    // MARK: - UI
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private let trackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray5
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        return label
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
        return label
    }()

    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .tertiaryLabel
        label.textAlignment = .right
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = .clear
        contentView.addSubview(containerView)
        
        containerView.addSubview(trackImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(artistLabel)
        containerView.addSubview(albumLabel)
        containerView.addSubview(infoStackView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12))
        }
        
        trackImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(6)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        infoStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(trackImageView.snp.top)
            make.leading.equalTo(trackImageView.snp.trailing).offset(12)
            make.trailing.equalTo(infoStackView.snp.leading).offset(-8)
        }

        artistLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel)
        }

        albumLabel.snp.makeConstraints { make in
            make.top.equalTo(artistLabel.snp.bottom).offset(2)
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel)
            make.bottom.lessThanOrEqualToSuperview().inset(12)
        }

        infoStackView.addArrangedSubview(playedAtLabel)
        infoStackView.addArrangedSubview(durationLabel)
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackImageView.kf.cancelDownloadTask()
        trackImageView.image = nil
        titleLabel.text = nil
        artistLabel.text = nil
        albumLabel.text = nil
        playedAtLabel.text = nil
        durationLabel.text = nil
    }
    
    // MARK: - Configure
    
    func configure(with track: RecentTrack) {
        titleLabel.text = track.track.name
        artistLabel.text = track.track.artists.map { $0.name }.joined(separator: ", ")
        albumLabel.text = track.track.album.name

        if let urlString = track.track.album.images.first?.url,
           let url = URL(string: urlString) {
            trackImageView.kf.setImage(with: url)
        } else {
            trackImageView.image = nil
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        playedAtLabel.text = formatter.localizedString(for: track.playedAt, relativeTo: Date())
        durationLabel.text = track.track.durationFormatted
    }
}

// MARK: - UITableViewDelegate

extension RecentTracksView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < tracks.count else { return }
        let track = tracks[indexPath.row]
        delegate?.recentTracksView(self, didSelect: track)
    }
}
