import UIKit
import Then
import SnapKit
import Kingfisher
import DomainKit

final class AlbumDetailView: UIView {
    // MARK: - UI
    private let tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 120
        $0.backgroundColor = CustomColor.clear
    }

    private let loadingIndicator = UIActivityIndicatorView(style: .large).then {
        $0.hidesWhenStopped = true
        $0.color = CustomColor.accent
    }

    private let emptyLabel = UILabel().then {
        $0.text = "트랙 정보를 불러올 수 없습니다."
        $0.textAlignment = .center
        $0.textColor = CustomColor.secondaryText
        $0.numberOfLines = 0
        $0.isHidden = true
    }

    private weak var albumInfoCellReference: AlbumInfoCell?

    // MARK: - Data
    private var album: SpotifyAlbum?
    private var tracks: [SpotifyAlbumTrack] = []
    var didSelectTrack: ((SpotifyAlbumTrack) -> Void)?

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
        backgroundColor = CustomColor.background
        addSubview(tableView)
        addSubview(loadingIndicator)
        addSubview(emptyLabel)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }

        tableView.register(AlbumInfoCell.self, forCellReuseIdentifier: AlbumInfoCell.identifier)
        tableView.register(RecentTrackCell.self, forCellReuseIdentifier: RecentTrackCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        let footerView = UIView(frame: .zero)
        footerView.backgroundColor = CustomColor.background
        tableView.tableFooterView = footerView
    }

    // MARK: - Exposed UI
    var copyURIButton: UIButton? {
        albumInfoCellReference?.copyURIButton
    }

    // MARK: - Update
    func configure(with album: SpotifyAlbum) {
        self.album = album
        tableView.reloadSections(IndexSet(integer: Section.info.rawValue), with: .none)
    }

    func updateTracks(_ tracks: [SpotifyAlbumTrack]) {
        self.tracks = tracks
        emptyLabel.isHidden = !tracks.isEmpty
        tableView.reloadSections(IndexSet(integer: Section.tracks.rawValue), with: .automatic)
    }

    func updateLoading(_ isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
            emptyLabel.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            emptyLabel.isHidden = !tracks.isEmpty
        }
    }
}

// MARK: - UITableViewDataSource
extension AlbumDetailView: UITableViewDataSource {
    enum Section: Int, CaseIterable {
        case info
        case tracks
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .info:
            return album == nil ? 0 : 1
        case .tracks:
            return tracks.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        switch section {
        case .info:
            guard let album else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: AlbumInfoCell.identifier, for: indexPath)
            if let infoCell = cell as? AlbumInfoCell {
                infoCell.configure(with: album)
                albumInfoCellReference = infoCell
            }
            cell.selectionStyle = .none
            return cell
        case .tracks:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: RecentTrackCell.identifier,
                for: indexPath
            ) as? RecentTrackCell else {
                return UITableViewCell()
            }
            let track = tracks[indexPath.row]
            cell.configure(with: makeTrackViewModel(from: track, index: indexPath.row + 1))
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension AlbumDetailView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { return nil }
        switch section {
        case .info:
            return nil
        case .tracks:
            return tracks.isEmpty ? nil : "트랙 목록"
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = Section(rawValue: section) else { return .leastNormalMagnitude }
        switch section {
        case .info:
            return .leastNormalMagnitude
        case .tracks:
            return tracks.isEmpty ? .leastNormalMagnitude : UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = Section(rawValue: indexPath.section) else { return UITableView.automaticDimension }
        switch section {
        case .info:
            return UITableView.automaticDimension
        case .tracks:
            return RecentTrackCell.cellHeight
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = Section(rawValue: indexPath.section), section == .tracks else { return }
        guard tracks.indices.contains(indexPath.row) else { return }
        didSelectTrack?(tracks[indexPath.row])
    }
}

private extension AlbumDetailView {
    func makeTrackViewModel(from track: SpotifyAlbumTrack, index: Int) -> RecentTrackCell.ViewModel {
        let albumArtworkURL = album?.images.first.flatMap { URL(string: $0.url) }
        let rankText = String(format: "%02d", index)

        return RecentTrackCell.ViewModel(
            titleText: track.name,
            artistText: track.artistNames,
            albumText: nil,
            playedAtText: nil,
            durationText: track.durationFormatted,
            rankText: rankText,
            artworkURL: albumArtworkURL,
            placeholderSystemName: "opticaldisc"
        )
    }
}

// MARK: - AlbumInfoCell
private final class AlbumInfoCell: UITableViewCell {
    static let identifier = String(describing: AlbumInfoCell.self)

    let coverImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        $0.backgroundColor = CustomColor.surfaceElevated
        $0.accessibilityIdentifier = "albumdetail_cover"
    }

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.numberOfLines = 2
        $0.textColor = CustomColor.primaryText
        $0.accessibilityIdentifier = "albumdetail_title"
    }

    private let artistsLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = CustomColor.secondaryText
        $0.numberOfLines = 0
        $0.accessibilityIdentifier = "albumdetail_artists"
    }

    private let releaseDateTitleLabel = AlbumInfoCell.makeTitleLabel(text: "발매일")
    private let releaseDateValueLabel = AlbumInfoCell.makeValueLabel(identifier: "albumdetail_release_date")
    private let totalTracksTitleLabel = AlbumInfoCell.makeTitleLabel(text: "총 트랙 수")
    private let totalTracksValueLabel = AlbumInfoCell.makeValueLabel(identifier: "albumdetail_total_tracks")
    private let idTitleLabel = AlbumInfoCell.makeTitleLabel(text: "앨범 ID")
    private let idValueLabel = AlbumInfoCell.makeValueLabel(identifier: "albumdetail_id")
    private let uriTitleLabel = AlbumInfoCell.makeTitleLabel(text: "Spotify URI")
    private let uriValueLabel = AlbumInfoCell.makeValueLabel(identifier: "albumdetail_uri")

    let copyURIButton = UIButton(type: .system).then {
        $0.setTitle("복사", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.setTitleColor(CustomColor.accent, for: .normal)
        $0.accessibilityIdentifier = "albumdetail_copy_uri"
    }

    private let infoStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
    }

    private let uriRow = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 8
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.kf.cancelDownloadTask()
        coverImageView.image = nil
    }

    private func setupLayout() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = CustomColor.surface
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        contentView.addSubview(coverImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(artistsLabel)
        contentView.addSubview(infoStack)

        infoStack.addArrangedSubview(makeInfoRow(titleLabel: releaseDateTitleLabel, valueLabel: releaseDateValueLabel))
        infoStack.addArrangedSubview(makeInfoRow(titleLabel: totalTracksTitleLabel, valueLabel: totalTracksValueLabel))
        infoStack.addArrangedSubview(makeInfoRow(titleLabel: idTitleLabel, valueLabel: idValueLabel))

        uriRow.addArrangedSubview(uriTitleLabel)
        uriRow.addArrangedSubview(UIView())
        uriRow.addArrangedSubview(copyURIButton)
        infoStack.addArrangedSubview(uriRow)
        infoStack.addArrangedSubview(uriValueLabel)

        coverImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(140)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(coverImageView)
            make.leading.equalTo(coverImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(16)
        }

        artistsLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(titleLabel)
        }

        infoStack.snp.makeConstraints { make in
            make.top.equalTo(coverImageView.snp.bottom).offset(16)
            make.leading.equalTo(coverImageView.snp.leading)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(20)
        }
    }

    func configure(with album: SpotifyAlbum) {
        titleLabel.text = album.name
        artistsLabel.text = album.artists.map { $0.name }.joined(separator: ", ")
        releaseDateValueLabel.text = album.releaseDate
        totalTracksValueLabel.text = "\(album.totalTracks)곡"
        idValueLabel.text = album.id
        uriValueLabel.text = album.uri

        if let urlString = album.images.first?.url, let url = URL(string: urlString) {
            coverImageView.kf.setImage(with: url)
        } else {
            coverImageView.image = UIImage(systemName: "opticaldisc")
            coverImageView.tintColor = CustomColor.secondaryText
        }
    }

    private static func makeTitleLabel(text: String) -> UILabel {
        return UILabel().then {
            $0.text = text
            $0.font = .systemFont(ofSize: 14, weight: .semibold)
            $0.textColor = CustomColor.secondaryText
        }
    }

    private static func makeValueLabel(identifier: String) -> UILabel {
        return UILabel().then {
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = CustomColor.primaryText
            $0.numberOfLines = 0
            $0.accessibilityIdentifier = identifier
        }
    }

    private func makeInfoRow(titleLabel: UILabel, valueLabel: UILabel) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }
}
