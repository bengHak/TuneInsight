import UIKit
import Then
import SnapKit
import Kingfisher
import DomainKit
import FoundationKit

final class ArtistDetailView: UIView {
    // MARK: - UI
    let scrollView = UIScrollView().then {
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = false
    }
    
    let contentView = UIView()
    
    let artistImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 0
        $0.backgroundColor = CustomColor.surfaceElevated
        $0.accessibilityIdentifier = "artistdetail_image"
    }

    let nameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.textColor = CustomColor.primaryText
        $0.numberOfLines = 2
        $0.accessibilityIdentifier = "artistdetail_name"
    }

    let popularityLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = CustomColor.secondaryText
        $0.accessibilityIdentifier = "artistdetail_popularity"
    }

    let genresTitleLabel = UILabel().then {
        $0.text = "common.genres".localized()
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = CustomColor.primaryText
    }

    let genresLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = CustomColor.secondaryText
        $0.numberOfLines = 0
        $0.accessibilityIdentifier = "artistdetail_genres"
    }

    private let openInSpotifyButton = UIButton(type: .system).then {
        $0.setTitle("spotify.openInApp".localized(), for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.setTitleColor(CustomColor.background, for: .normal)
        $0.backgroundColor = CustomColor.accent
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.accessibilityIdentifier = "artistdetail_open_spotify"
    }
    
    let albumsTitleLabel = UILabel().then {
        $0.text = "artist.featuredAlbumsTitle".localized()
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = CustomColor.primaryText
        $0.isHidden = true
    }
    
    private lazy var albumsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.register(AlbumCell.self, forCellWithReuseIdentifier: AlbumCell.identifier)
        cv.isHidden = true
        return cv
    }()
    
    private var albumItems: [SpotifyAlbum] = []
    var didSelectAlbum: ((SpotifyAlbum) -> Void)?
    private var topTrackItems: [SpotifyTrack] = []
    var didSelectTrack: ((SpotifyTrack) -> Void)?
    public var didTapOpenInSpotify: ((String) -> Void)?
    private var spotifyURI: String?
    private var openInSpotifyButtonHeightConstraint: Constraint?
    
    let topTracksTitleLabel = UILabel().then {
        $0.text = "artist.topTracksTitle".localized()
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = CustomColor.primaryText
        $0.isHidden = true
    }

    private let topTracksTableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = CustomColor.clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.isScrollEnabled = false
        tv.rowHeight = TrackCell.cellHeight
        tv.register(TrackCell.self, forCellReuseIdentifier: TrackCell.identifier)
        return tv
    }()

    private var topTracksTableHeightConstraint: Constraint?
    
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
        scrollView.backgroundColor = .clear
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.backgroundColor = CustomColor.background
        
        contentView.addSubview(artistImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(popularityLabel)
        contentView.addSubview(genresTitleLabel)
        contentView.addSubview(genresLabel)
        contentView.addSubview(openInSpotifyButton)
        contentView.addSubview(albumsTitleLabel)
        contentView.addSubview(albumsCollectionView)
        contentView.addSubview(topTracksTitleLabel)
        contentView.addSubview(topTracksTableView)

        openInSpotifyButton.addTarget(self, action: #selector(openInSpotifyButtonTapped), for: .touchUpInside)

        topTracksTableView.dataSource = self
        topTracksTableView.delegate = self
        let footerView = UIView()
        footerView.backgroundColor = CustomColor.background
        topTracksTableView.tableFooterView = footerView

        setupConstraints()
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        artistImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(artistImageView.snp.width)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(artistImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        popularityLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(nameLabel)
        }
        
        genresTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(popularityLabel.snp.bottom).offset(16)
            make.leading.trailing.equalTo(nameLabel)
        }
        
        genresLabel.snp.makeConstraints { make in
            make.top.equalTo(genresTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(nameLabel)
        }
        
        openInSpotifyButton.snp.makeConstraints { make in
            make.top.equalTo(genresLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(nameLabel)
            openInSpotifyButtonHeightConstraint = make.height.equalTo(48).constraint
        }

        albumsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(openInSpotifyButton.snp.bottom).offset(24)
            make.leading.trailing.equalTo(nameLabel)
        }
        
        albumsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(albumsTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(160)
        }
        
        topTracksTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(albumsCollectionView.snp.bottom).offset(16)
            make.leading.trailing.equalTo(nameLabel)
        }
        
        topTracksTableView.snp.makeConstraints { make in
            make.top.equalTo(topTracksTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            topTracksTableHeightConstraint = make.height.equalTo(0).constraint
            make.bottom.equalToSuperview().inset(24)
        }
    }
    
    // MARK: - Update
    func configure(with artist: SpotifyArtist) {
        nameLabel.text = artist.name
        if let popularity = artist.popularity {
            popularityLabel.text = "track.popularityFormat".localizedFormat(popularity)
        } else {
            popularityLabel.text = "track.popularityUnavailable".localized()
        }
        
        genresLabel.text = artist.genres.isEmpty ? "-" : artist.genres.joined(separator: ", ")
        spotifyURI = artist.uri
        let shouldHideOpenButton = artist.uri.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        openInSpotifyButton.isHidden = shouldHideOpenButton
        openInSpotifyButton.isEnabled = !shouldHideOpenButton
        openInSpotifyButtonHeightConstraint?.update(offset: shouldHideOpenButton ? 0 : 48)

        if let urlString = artist.images.first?.url, let url = URL(string: urlString) {
            artistImageView.kf.setImage(with: url)
        } else {
            artistImageView.image = UIImage(systemName: "person.crop.square")
            artistImageView.tintColor = CustomColor.secondaryText
        }
    }
    
    func updateAlbums(_ albums: [SpotifyAlbum]) {
        albumItems = Array(albums.prefix(20))
        let isEmpty = albumItems.isEmpty
        albumsTitleLabel.isHidden = isEmpty
        albumsCollectionView.isHidden = isEmpty
        albumsCollectionView.reloadData()
    }
    
    func updateTopTracks(_ tracks: [SpotifyTrack]) {
        topTrackItems = Array(tracks.prefix(20))
        let isEmpty = topTrackItems.isEmpty
        topTracksTitleLabel.isHidden = isEmpty
        topTracksTableView.isHidden = isEmpty
        topTracksTableView.reloadData()

        let contentHeight = isEmpty ? 0 : CGFloat(topTrackItems.count) * TrackCell.cellHeight
        topTracksTableHeightConstraint?.update(offset: contentHeight)
        layoutIfNeeded()
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension ArtistDetailView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumCell.identifier, for: indexPath) as? AlbumCell else {
            return UICollectionViewCell()
        }
        let album = albumItems[indexPath.item]
        cell.configure(with: album)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 220, height: 96)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard albumItems.indices.contains(indexPath.item) else { return }
        didSelectAlbum?(albumItems[indexPath.item])
    }
}

// MARK: - UITableViewDataSource & Delegate
extension ArtistDetailView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        topTrackItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TrackCell.identifier,
            for: indexPath
        ) as? TrackCell else {
            return UITableViewCell()
        }

        let track = topTrackItems[indexPath.row]
        cell.configure(with: makeTopTrackViewModel(from: track, index: indexPath.row + 1))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard topTrackItems.indices.contains(indexPath.row) else { return }
        didSelectTrack?(topTrackItems[indexPath.row])
    }
}

private extension ArtistDetailView {
    func makeTopTrackViewModel(from track: SpotifyTrack, index: Int) -> TrackCell.ViewModel {
        let artworkURL = track.album.images.first.flatMap { URL(string: $0.url) }
        let rankText = String(format: "%02d", index)

        return TrackCell.ViewModel(
            titleText: track.name,
            artistText: track.artistNames,
            albumText: track.album.name,
            playedAtText: nil,
            durationText: track.durationFormatted,
            rankText: rankText,
            artworkURL: artworkURL
        )
    }

    @objc func openInSpotifyButtonTapped() {
        guard let uri = spotifyURI else { return }
        didTapOpenInSpotify?(uri)
    }
}

// MARK: - Album Cell
private final class AlbumCell: UICollectionViewCell {
    static let identifier = String(describing: AlbumCell.self)
    
    private let containerView = UIView().then {
        $0.backgroundColor = CustomColor.surface
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = CustomColor.border.cgColor
        $0.clipsToBounds = true
    }

    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = CustomColor.border.cgColor
        $0.backgroundColor = CustomColor.surfaceElevated
    }

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13, weight: .semibold)
        $0.textColor = CustomColor.primaryText
        $0.numberOfLines = 2
    }

    private let artistLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 11, weight: .regular)
        $0.textColor = CustomColor.secondaryText
        $0.numberOfLines = 1
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = CustomColor.background
        contentView.backgroundColor = CustomColor.background
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(artistLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(4)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(88)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(14)
            make.leading.equalTo(imageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(12)
        }

        artistLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.bottom.lessThanOrEqualToSuperview().inset(14)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
