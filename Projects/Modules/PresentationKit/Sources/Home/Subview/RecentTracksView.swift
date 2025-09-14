import UIKit
import SnapKit
import DomainKit
import Kingfisher

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
        tv.rowHeight = 64
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        return tv
    }()
    
    // MARK: - Properties
    
    private var tracks: [RecentTrack] = []
    
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
        backgroundColor = .systemBackground
        addSubview(titleLabel)
        addSubview(tableView)
        tableView.dataSource = self
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
        let rowHeight: CGFloat = 64
        let tableHeight = CGFloat(tracks.count) * rowHeight

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
    
    // MARK: - UI
    
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
    
    private let playedAtLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .tertiaryLabel
        label.textAlignment = .right
        return label
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
        
        contentView.addSubview(trackImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(artistLabel)
        contentView.addSubview(playedAtLabel)
        
        trackImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        playedAtLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(trackImageView.snp.top)
            make.leading.equalTo(trackImageView.snp.trailing).offset(12)
            make.trailing.equalTo(playedAtLabel.snp.leading).offset(-8)
        }
        
        artistLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel)
        }
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackImageView.kf.cancelDownloadTask()
        trackImageView.image = nil
        titleLabel.text = nil
        artistLabel.text = nil
        playedAtLabel.text = nil
    }
    
    // MARK: - Configure
    
    func configure(with track: RecentTrack) {
        titleLabel.text = track.track.name
        artistLabel.text = track.track.artists.map { $0.name }.joined(separator: ", ")
        
        if let urlString = track.track.album.images.first?.url,
           let url = URL(string: urlString) {
            trackImageView.kf.setImage(with: url)
        } else {
            trackImageView.image = nil
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        playedAtLabel.text = formatter.localizedString(for: track.playedAt, relativeTo: Date())
    }
}
