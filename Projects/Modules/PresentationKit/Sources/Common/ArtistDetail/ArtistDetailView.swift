import UIKit
import Then
import SnapKit
import Kingfisher
import DomainKit

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
        $0.backgroundColor = .secondarySystemBackground
        $0.accessibilityIdentifier = "artistdetail_image"
    }
    
    let nameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.textColor = .label
        $0.numberOfLines = 2
        $0.accessibilityIdentifier = "artistdetail_name"
    }
    
    let popularityLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = .secondaryLabel
        $0.accessibilityIdentifier = "artistdetail_popularity"
    }
    
    let genresTitleLabel = UILabel().then {
        $0.text = "장르"
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = .label
    }
    
    let genresLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = .label
        $0.numberOfLines = 0
        $0.accessibilityIdentifier = "artistdetail_genres"
    }
    
    let idTitleLabel = UILabel().then {
        $0.text = "아티스트 ID"
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = .secondaryLabel
    }
    
    let idValueLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .tertiaryLabel
        $0.numberOfLines = 1
        $0.accessibilityIdentifier = "artistdetail_id"
    }
    
    let uriTitleLabel = UILabel().then {
        $0.text = "Spotify URI"
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = .secondaryLabel
    }
    
    let uriValueLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .tertiaryLabel
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingMiddle
        $0.accessibilityIdentifier = "artistdetail_uri"
    }
    
    let copyURIButton = UIButton(type: .system).then {
        $0.setTitle("복사", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.accessibilityIdentifier = "artistdetail_copy_uri"
    }
    
    let albumsTitleLabel = UILabel().then {
        $0.text = "대표 앨범"
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = .label
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
    
    let topTracksTitleLabel = UILabel().then {
        $0.text = "인기 트랙"
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = .label
        $0.isHidden = true
    }
    
    private lazy var topTracksCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isHidden = true
        cv.isScrollEnabled = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(TopTrackCell.self, forCellWithReuseIdentifier: TopTrackCell.identifier)
        return cv
    }()
    
    private var topTracksCollectionHeightConstraint: Constraint?
    
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
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(artistImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(popularityLabel)
        contentView.addSubview(genresTitleLabel)
        contentView.addSubview(genresLabel)
        contentView.addSubview(idTitleLabel)
        contentView.addSubview(idValueLabel)
        contentView.addSubview(uriTitleLabel)
        contentView.addSubview(uriValueLabel)
        contentView.addSubview(copyURIButton)
        contentView.addSubview(albumsTitleLabel)
        contentView.addSubview(albumsCollectionView)
        contentView.addSubview(topTracksTitleLabel)
        contentView.addSubview(topTracksCollectionView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
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
        
        idTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(genresLabel.snp.bottom).offset(16)
            make.leading.trailing.equalTo(nameLabel)
        }
        
        idValueLabel.snp.makeConstraints { make in
            make.top.equalTo(idTitleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(nameLabel)
        }
        
        uriTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(idValueLabel.snp.bottom).offset(12)
            make.leading.equalTo(nameLabel)
        }
        
        copyURIButton.snp.makeConstraints { make in
            make.centerY.equalTo(uriTitleLabel.snp.centerY)
            make.trailing.equalTo(nameLabel.snp.trailing)
        }
        
        uriValueLabel.snp.makeConstraints { make in
            make.top.equalTo(uriTitleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(nameLabel)
        }
        
        albumsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(uriValueLabel.snp.bottom).offset(16)
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
        
        topTracksCollectionView.snp.makeConstraints { make in
            make.top.equalTo(topTracksTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            topTracksCollectionHeightConstraint = make.height.equalTo(0).constraint
            make.bottom.equalToSuperview().inset(24)
        }
    }
    
    // MARK: - Update
    func configure(with artist: SpotifyArtist) {
        nameLabel.text = artist.name
        if let popularity = artist.popularity {
            popularityLabel.text = "인기도: \(popularity)"
        } else {
            popularityLabel.text = "인기도: -"
        }
        
        genresLabel.text = artist.genres.isEmpty ? "-" : artist.genres.joined(separator: ", ")
        idValueLabel.text = artist.id
        uriValueLabel.text = artist.uri
        
        if let urlString = artist.images.first?.url, let url = URL(string: urlString) {
            artistImageView.kf.setImage(with: url)
        } else {
            artistImageView.image = UIImage(systemName: "person.crop.square")
            artistImageView.tintColor = .systemGray3
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
        topTracksCollectionView.isHidden = isEmpty
        topTracksCollectionView.reloadData()

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.topTracksCollectionView.collectionViewLayout.invalidateLayout()
            self.topTracksCollectionView.layoutIfNeeded()
            let contentHeight = isEmpty ? 0 : self.topTracksCollectionView.collectionViewLayout.collectionViewContentSize.height
            self.topTracksCollectionHeightConstraint?.update(offset: contentHeight)
            self.layoutIfNeeded()
        }
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension ArtistDetailView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === albumsCollectionView {
            return albumItems.count
        }
        return topTrackItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === albumsCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumCell.identifier, for: indexPath) as? AlbumCell else {
                return UICollectionViewCell()
            }
            let album = albumItems[indexPath.item]
            cell.configure(with: album)
            return cell
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopTrackCell.identifier, for: indexPath) as? TopTrackCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: topTrackItems[indexPath.item], index: indexPath.item + 1)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView === albumsCollectionView {
            return CGSize(width: 220, height: 96)
        }
        let layout = collectionViewLayout as? UICollectionViewFlowLayout
        let horizontalInset = (layout?.sectionInset.left ?? 0) + (layout?.sectionInset.right ?? 0)
        let width = collectionView.bounds.width - horizontalInset
        return CGSize(width: width, height: 88)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === albumsCollectionView {
            guard albumItems.indices.contains(indexPath.item) else { return }
            didSelectAlbum?(albumItems[indexPath.item])
        } else {
            guard topTrackItems.indices.contains(indexPath.item) else { return }
            didSelectTrack?(topTrackItems[indexPath.item])
        }
    }
}

// MARK: - Album Cell
private final class AlbumCell: UICollectionViewCell {
    static let identifier = String(describing: AlbumCell.self)
    
    private let containerView = UIView().then {
        $0.backgroundColor = .secondarySystemBackground
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }

    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .tertiarySystemFill
    }

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13, weight: .semibold)
        $0.textColor = .label
        $0.numberOfLines = 2
    }

    private let artistLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 11, weight: .regular)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 1
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(artistLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(64)
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
            imageView.tintColor = .systemGray3
        }
    }
}

private final class TopTrackCell: UICollectionViewCell {
    static let identifier = "TopTrackCell"

    private let containerView = UIView().then {
        $0.backgroundColor = .secondarySystemBackground
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }

    private let albumImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .tertiarySystemFill
    }

    private let indexLabel = UILabel().then {
        $0.font = .monospacedDigitSystemFont(ofSize: 14, weight: .semibold)
        $0.textColor = .secondaryLabel
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = .label
        $0.numberOfLines = 2
    }

    private let artistLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 1
    }

    private let durationLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textColor = .tertiaryLabel
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(containerView)
        containerView.addSubview(albumImageView)
        containerView.addSubview(indexLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(artistLabel)
        containerView.addSubview(durationLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        albumImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(56)
        }

        indexLabel.snp.makeConstraints { make in
            make.leading.equalTo(albumImageView.snp.trailing).offset(12)
            make.top.equalTo(albumImageView.snp.top)
        }

        durationLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(albumImageView.snp.top)
            make.leading.equalTo(indexLabel.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualTo(durationLabel.snp.leading).offset(-8)
        }

        artistLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.lessThanOrEqualTo(durationLabel.snp.leading).offset(-8)
            make.bottom.lessThanOrEqualToSuperview().inset(12)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        indexLabel.text = nil
        titleLabel.text = nil
        artistLabel.text = nil
        durationLabel.text = nil
        albumImageView.kf.cancelDownloadTask()
        albumImageView.image = nil
    }

    func configure(with track: SpotifyTrack, index: Int) {
        indexLabel.text = String(format: "%02d", index)
        titleLabel.text = track.name
        artistLabel.text = track.artistNames
        durationLabel.text = track.durationFormatted
        if let urlString = track.album.images.first?.url, let url = URL(string: urlString) {
            albumImageView.kf.setImage(with: url)
        } else {
            albumImageView.image = UIImage(systemName: "music.note")
            albumImageView.tintColor = .systemGray3
        }
    }
}
