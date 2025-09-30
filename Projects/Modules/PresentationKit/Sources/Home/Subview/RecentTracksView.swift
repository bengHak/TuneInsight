import UIKit
import SnapKit
import DomainKit

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
    private let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()
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
        cell.configure(with: makeViewModel(from: track))
        return cell
    }
}

private extension RecentTracksView {
    func makeViewModel(from track: RecentTrack) -> RecentTrackCell.ViewModel {
        let artworkURL = track.track.album.images.first.flatMap { URL(string: $0.url) }
        let playedAtText = relativeDateFormatter.localizedString(for: track.playedAt, relativeTo: Date())

        return RecentTrackCell.ViewModel(
            titleText: track.track.name,
            artistText: track.track.artists.map { $0.name }.joined(separator: ", "),
            albumText: track.track.album.name,
            playedAtText: playedAtText,
            durationText: track.track.durationFormatted,
            rankText: nil,
            artworkURL: artworkURL
        )
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
