import UIKit
import Then
import SnapKit
import Kingfisher
import DomainKit

final class AlbumDetailView: UIView {
    // MARK: - UI
    private let tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.separatorStyle = .singleLine
        $0.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        $0.showsVerticalScrollIndicator = false
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 120
        $0.backgroundColor = .systemBackground
    }

    private let loadingIndicator = UIActivityIndicatorView(style: .large).then {
        $0.hidesWhenStopped = true
    }

    private let emptyLabel = UILabel().then {
        $0.text = "트랙 정보를 불러올 수 없습니다."
        $0.textAlignment = .center
        $0.textColor = .secondaryLabel
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
        backgroundColor = .systemBackground

        addSubview(tableView)
        addSubview(loadingIndicator)
        addSubview(emptyLabel)

        tableView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }

        tableView.register(AlbumInfoCell.self, forCellReuseIdentifier: AlbumInfoCell.identifier)
        tableView.register(AlbumTrackCell.self, forCellReuseIdentifier: AlbumTrackCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: .zero)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: AlbumTrackCell.identifier, for: indexPath)
            if let trackCell = cell as? AlbumTrackCell {
                let track = tracks[indexPath.row]
                trackCell.configure(with: track, index: indexPath.row + 1)
            }
            cell.selectionStyle = .default
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = Section(rawValue: indexPath.section), section == .tracks else { return }
        guard tracks.indices.contains(indexPath.row) else { return }
        didSelectTrack?(tracks[indexPath.row])
    }
}

// MARK: - AlbumInfoCell
private final class AlbumInfoCell: UITableViewCell {
    static let identifier = String(describing: AlbumInfoCell.self)

    let coverImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        $0.backgroundColor = .secondarySystemBackground
        $0.accessibilityIdentifier = "albumdetail_cover"
    }

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.numberOfLines = 2
        $0.textColor = .label
        $0.accessibilityIdentifier = "albumdetail_title"
    }

    private let artistsLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .secondaryLabel
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
        contentView.backgroundColor = .systemBackground

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
            coverImageView.tintColor = .systemGray3
        }
    }

    private static func makeTitleLabel(text: String) -> UILabel {
        return UILabel().then {
            $0.text = text
            $0.font = .systemFont(ofSize: 14, weight: .semibold)
            $0.textColor = .secondaryLabel
        }
    }

    private static func makeValueLabel(identifier: String) -> UILabel {
        return UILabel().then {
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .label
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

// MARK: - AlbumTrackCell
private final class AlbumTrackCell: UITableViewCell {
    static let identifier = String(describing: AlbumTrackCell.self)

    private let indexLabel = UILabel().then {
        $0.font = .monospacedDigitSystemFont(ofSize: 14, weight: .semibold)
        $0.textColor = .secondaryLabel
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .label
        $0.numberOfLines = 0
    }

    private let artistsLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 0
    }

    private let metaLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textColor = .tertiaryLabel
        $0.numberOfLines = 0
    }

    private let availabilityLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textColor = .tertiaryLabel
        $0.numberOfLines = 0
    }

    private let previewTitleLabel = UILabel().then {
        $0.text = "미리듣기"
        $0.font = .systemFont(ofSize: 12, weight: .semibold)
        $0.textColor = .secondaryLabel
    }

    private let previewValueLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textColor = .label
        $0.numberOfLines = 0
    }

    private let uriTitleLabel = UILabel().then {
        $0.text = "URI"
        $0.font = .systemFont(ofSize: 12, weight: .semibold)
        $0.textColor = .secondaryLabel
    }

    private let uriValueLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textColor = .label
        $0.numberOfLines = 0
        $0.lineBreakMode = .byTruncatingMiddle
    }

    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 6
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
        titleLabel.text = nil
        artistsLabel.text = nil
        metaLabel.text = nil
        availabilityLabel.text = nil
        previewValueLabel.text = nil
        uriValueLabel.text = nil
    }

    private func setupLayout() {
        selectionStyle = .default
        accessoryType = .disclosureIndicator
        contentView.backgroundColor = .systemBackground

        contentView.addSubview(indexLabel)
        contentView.addSubview(stackView)

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(artistsLabel)
        stackView.addArrangedSubview(metaLabel)
        stackView.addArrangedSubview(availabilityLabel)

        let previewStack = UIStackView(arrangedSubviews: [previewTitleLabel, previewValueLabel])
        previewStack.axis = .vertical
        previewStack.spacing = 2
        stackView.addArrangedSubview(previewStack)

        let uriStack = UIStackView(arrangedSubviews: [uriTitleLabel, uriValueLabel])
        uriStack.axis = .vertical
        uriStack.spacing = 2
        stackView.addArrangedSubview(uriStack)

        indexLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }

        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(indexLabel.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(12)
        }
    }

    func configure(with track: SpotifyAlbumTrack, index: Int) {
        indexLabel.text = String(format: "%02d", index)
        titleLabel.text = track.name
        artistsLabel.text = track.artistNames

        let explicitText = track.explicit ? "익스플리싯" : "클린"
        metaLabel.text = "디스크 \(track.discNumber) • 트랙 \(track.trackNumber) • \(track.durationFormatted) • \(explicitText)"

        var availabilityComponents: [String] = []
        if let isPlayable = track.isPlayable {
            availabilityComponents.append(isPlayable ? "재생 가능" : "재생 불가")
        }
        availabilityComponents.append(track.isLocal ? "로컬 트랙" : "스트리밍")
        availabilityComponents.append("서비스 지역: \(track.availableMarketsDescription)")
        if let restriction = track.restrictions?.reason {
            availabilityComponents.append("제한: \(restriction)")
        }
        availabilityLabel.text = availabilityComponents.joined(separator: " • ")

        if let preview = track.previewUrl, !preview.isEmpty {
            previewValueLabel.text = preview
        } else {
            previewValueLabel.text = "제공되지 않음"
        }
        uriValueLabel.text = track.uri
    }
}
