import UIKit
import SnapKit
import DomainKit
import Kingfisher

public final class HomeTopPlayedArtistView: UIView {
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "가장 많이 들은 아티스트"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(TopArtistCell.self, forCellWithReuseIdentifier: TopArtistCell.identifier)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        return cv
    }()
    
    // MARK: - Properties
    
    private var artists: [TopArtist] = []
    
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
        addSubview(collectionView)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        self.snp.makeConstraints { make in
            make.height.equalTo(88) // 초기 최소 높이 (타이틀만 있을 때)
        }
    }
    
    // MARK: - Public
    
    public func updateArtists(_ artists: [TopArtist]) {
        self.artists = Array(artists.prefix(6))
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
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
        let titleHeight: CGFloat = 44
        let cellHeight: CGFloat = 120
        let verticalSpacing: CGFloat = 16
        let padding: CGFloat = 32
        
        let rows = min(ceil(Double(artists.count) / 2.0), 3)
        let collectionHeight = (cellHeight * CGFloat(rows)) + (verticalSpacing * CGFloat(max(0, rows - 1))) + padding
        
        return titleHeight + collectionHeight
    }
}

// MARK: - UICollectionViewDataSource

extension HomeTopPlayedArtistView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(artists.count, 6)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TopArtistCell.identifier,
            for: indexPath
        ) as? TopArtistCell else {
            assertionFailure("TopArtistCell not registered")
            return UICollectionViewCell()
        }
        
        let artist = artists[indexPath.item]
        cell.configure(with: artist)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeTopPlayedArtistView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 48
        let cellWidth = (collectionView.bounds.width - padding) / 2
        return CGSize(width: cellWidth, height: 120)
    }
}

// MARK: - TopArtistCell

private final class TopArtistCell: UICollectionViewCell {
    
    static let identifier = String(describing: TopArtistCell.self)
    
    // MARK: - UI
    
    private let artistImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.backgroundColor = .systemGray5
        return imageView
    }()
    
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.backgroundColor = .systemBlue
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(artistImageView)
        contentView.addSubview(rankLabel)
        contentView.addSubview(artistNameLabel)
        
        artistImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(70)
        }
        
        rankLabel.snp.makeConstraints { make in
            make.top.equalTo(artistImageView.snp.top)
            make.trailing.equalTo(artistImageView.snp.trailing).offset(5)
            make.width.height.equalTo(20)
        }
        
        artistNameLabel.snp.makeConstraints { make in
            make.top.equalTo(artistImageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(4)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
        }
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        artistImageView.kf.cancelDownloadTask()
        artistImageView.image = nil
        artistNameLabel.text = nil
        rankLabel.text = nil
    }
    
    // MARK: - Configure
    
    func configure(with artist: TopArtist) {
        artistNameLabel.text = artist.name
        
        if let rank = artist.rank {
            rankLabel.text = "\(rank)"
            rankLabel.isHidden = false
        } else {
            rankLabel.isHidden = true
        }
        
        if let urlString = artist.images.first?.url,
           let url = URL(string: urlString) {
            artistImageView.kf.setImage(with: url)
        } else {
            artistImageView.image = UIImage(systemName: "person.circle.fill")
            artistImageView.tintColor = .systemGray3
        }
    }
}
