import UIKit
import Then
import SnapKit
import Kingfisher
import DomainKit
import FoundationKit

final class TrackDetailView: UIView {
    // MARK: - UI
    private let scrollView = UIScrollView().then {
        $0.backgroundColor = .clear
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = false
        $0.refreshControl = UIRefreshControl()
        $0.refreshControl?.tintColor = CustomColor.accent
        $0.contentInset = .init(top: 0, left: 0, bottom: 160, right: 0)
    }

    private let contentView = UIView()

    private let albumImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = CustomColor.surfaceElevated
        $0.accessibilityIdentifier = "trackdetail_album_image"
    }

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 22, weight: .bold)
        $0.textColor = CustomColor.primaryText
        $0.numberOfLines = 2
        $0.accessibilityIdentifier = "trackdetail_title"
    }

    private let artistLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = CustomColor.secondaryText
        $0.numberOfLines = 1
        $0.accessibilityIdentifier = "trackdetail_artist"
    }

    private let albumLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = CustomColor.tertiaryText
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
        $0.textColor = CustomColor.secondaryText
        $0.accessibilityIdentifier = "trackdetail_duration"
    }

    private let popularityLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = CustomColor.secondaryText
        $0.accessibilityIdentifier = "trackdetail_popularity"
    }

    private let albumSectionTitleLabel = UILabel().then {
        $0.text = "common.album".localized()
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.textColor = CustomColor.primaryText
        $0.isHidden = true
    }

    let albumCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.isHidden = true
        return collectionView
    }()

    let addToQueueButton = UIButton(type: .system).then {
        $0.setTitle("playlist.addToQueueButton".localized(), for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.tintColor = CustomColor.background
        $0.backgroundColor = CustomColor.accent
        $0.layer.cornerRadius = 10
        $0.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        $0.accessibilityIdentifier = "trackdetail_add_to_queue"
    }

    let skipNextButton = UIButton(type: .system).then {
        $0.setTitle("player.playNowButton".localized(), for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.tintColor = CustomColor.accent
        $0.backgroundColor = CustomColor.surface
        $0.layer.borderWidth = 1
        $0.layer.borderColor = CustomColor.accent.cgColor
        $0.layer.cornerRadius = 10
        $0.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        $0.accessibilityIdentifier = "trackdetail_skip_next"
    }

    // 고정 플레이어 뷰 외부에서 주입받기 위한 컨테이너
    let playerContainerView = UIView().then {
        $0.backgroundColor = .clear
        $0.accessibilityIdentifier = "trackdetail_player_container"
    }

    // MARK: - Public Properties
    var refreshControl: UIRefreshControl? {
        return scrollView.refreshControl
    }

    // MARK: - Callbacks
    var didSelectAlbum: ((SpotifyAlbum) -> Void)?

    // MARK: - Data
    private var albumItems: [SpotifyAlbum] = []

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
        contentView.backgroundColor = CustomColor.background

        addSubview(scrollView)
        addSubview(playerContainerView)
        scrollView.addSubview(contentView)

        contentView.addSubview(albumImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(artistLabel)
        contentView.addSubview(albumLabel)
        contentView.addSubview(infoStack)
        contentView.addSubview(albumSectionTitleLabel)
        contentView.addSubview(albumCollectionView)
        contentView.addSubview(addToQueueButton)
        contentView.addSubview(skipNextButton)

        infoStack.addArrangedSubview(durationLabel)
        infoStack.addArrangedSubview(popularityLabel)

        albumCollectionView.register(AlbumSummaryCell.self, forCellWithReuseIdentifier: AlbumSummaryCell.identifier)
        albumCollectionView.dataSource = self
        albumCollectionView.delegate = self

        setupConstraints()
    }

    private func setupConstraints() {
        playerContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(self.snp.width)
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

        albumSectionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(infoStack.snp.bottom).offset(24)
            make.leading.trailing.equalTo(titleLabel)
        }

        albumCollectionView.snp.makeConstraints { make in
            make.top.equalTo(albumSectionTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(180)
        }

        addToQueueButton.snp.makeConstraints { make in
            make.top.equalTo(albumCollectionView.snp.bottom).offset(24)
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
        durationLabel.text = "track.durationFormat".localizedFormat(track.durationFormatted)
        popularityLabel.text = "track.popularityFormat".localizedFormat(track.popularity)

        if let urlString = track.albumImageUrl, let url = URL(string: urlString) {
            albumImageView.kf.setImage(with: url)
        } else {
            albumImageView.image = nil
        }

        albumItems = [track.album]
        let hasAlbum = !albumItems.isEmpty
        albumSectionTitleLabel.isHidden = !hasAlbum
        albumCollectionView.isHidden = !hasAlbum
        albumCollectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension TrackDetailView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        albumItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumSummaryCell.identifier, for: indexPath) as? AlbumSummaryCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: albumItems[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 140, height: 180)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard albumItems.indices.contains(indexPath.item) else { return }
        didSelectAlbum?(albumItems[indexPath.item])
    }
}

// MARK: - AlbumSummaryCell
private final class AlbumSummaryCell: UICollectionViewCell {
    static let identifier = "AlbumSummaryCell"

    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.backgroundColor = CustomColor.surfaceElevated
    }

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = CustomColor.primaryText
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }

    private let artistLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textColor = CustomColor.secondaryText
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(artistLabel)
        contentView.backgroundColor = CustomColor.surface
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(140)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(4)
        }

        artistLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview().inset(4)
            make.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        titleLabel.text = nil
        artistLabel.text = nil
    }

    func configure(with album: SpotifyAlbum) {
        titleLabel.text = album.name
        artistLabel.text = album.artists.map { $0.name }.joined(separator: ", ")
        if let urlString = album.images.first?.url, let url = URL(string: urlString) {
            imageView.kf.setImage(with: url)
        } else {
            imageView.image = UIImage(systemName: "opticaldisc")
            imageView.tintColor = CustomColor.secondaryText
        }
    }
}
