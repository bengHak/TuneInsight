import SwiftUI
import UIKit
import Then
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa
import DomainKit
import Kingfisher

public final class StatisticsViewController: UIViewController, ReactorKit.View {
    public var disposeBag = DisposeBag()
    public weak var coordinator: StatisticsCoordinator?

    // MARK: - UI
    private let segmentedControl: UISegmentedControl = {
        let items = SpotifyTimeRange.allCases.map { $0.displayName }
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = SpotifyTimeRange.allCases.firstIndex(of: .mediumTerm) ?? 1
        sc.backgroundColor = .secondarySystemBackground
        sc.selectedSegmentTintColor = .systemGreen
        return sc
    }()

    private let tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .singleLine
        $0.tableFooterView = UIView()
        $0.rowHeight = 64
        $0.register(TopArtistRowCell.self, forCellReuseIdentifier: TopArtistRowCell.identifier)
        $0.accessibilityIdentifier = "statistics_artists_table"
    }

    private let emptyLabel = UILabel().then {
        $0.text = "데이터가 없습니다."
        $0.textColor = .secondaryLabel
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.textAlignment = .center
        $0.isHidden = true
    }

    private let loadingIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.hidesWhenStopped = true
    }

    // MARK: - Data
    private var items: [TopArtist] = []

    // MARK: - Init
    public init(reactor: StatisticsReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "통계"
        view.backgroundColor = .systemBackground

        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(loadingIndicator)

        tableView.dataSource = self
        tableView.delegate = self

        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(32)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        emptyLabel.snp.makeConstraints { make in
            make.center.equalTo(tableView)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(segmentedControl.snp.bottom).offset(8)
        }
    }

    // MARK: - Reactor
    public func bind(reactor: StatisticsReactor) {
        // Actions
        rx.methodInvoked(#selector(viewDidLoad))
            .map { _ in Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        segmentedControl.rx.selectedSegmentIndex
            .compactMap { index in SpotifyTimeRange.allCases[safe: index] }
            .map { Reactor.Action.selectTimeRange($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // State
        reactor.state.map { $0.topArtists }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] artists in
                self?.items = artists
                self?.tableView.reloadData()
                self?.emptyLabel.isHidden = !artists.isEmpty
            }
            .disposed(by: disposeBag)

        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] isLoading in
                if isLoading { self?.loadingIndicator.startAnimating() }
                else { self?.loadingIndicator.stopAnimating() }
            }
            .disposed(by: disposeBag)

        reactor.state.map { $0.errorMessage }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] message in
                self?.showError(message: message)
            }
            .disposed(by: disposeBag)
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource/Delegate
extension StatisticsViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TopArtistRowCell.identifier, for: indexPath) as? TopArtistRowCell else {
            return UITableViewCell()
        }
        cell.configure(with: items[indexPath.row])
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < items.count else { return }
        coordinator?.showArtistDetail(items[indexPath.row].artist)
    }
}

// MARK: - TopArtistRowCell
private final class TopArtistRowCell: UITableViewCell {
    static let identifier = String(describing: TopArtistRowCell.self)

    private let rankLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .bold)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.backgroundColor = .systemGreen
        $0.layer.cornerRadius = 14
        $0.layer.masksToBounds = true
        $0.widthAnchor.constraint(equalToConstant: 28).isActive = true
        $0.heightAnchor.constraint(equalToConstant: 28).isActive = true
    }

    private let avatarView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .systemGray5
        $0.widthAnchor.constraint(equalToConstant: 44).isActive = true
        $0.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }

    private let nameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = .label
        $0.numberOfLines = 1
    }

    private let subLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 1
    }

    private let hStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .center
    }

    private let vStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 2
        $0.alignment = .fill
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        selectionStyle = .default
        vStack.addArrangedSubview(nameLabel)
        vStack.addArrangedSubview(subLabel)

        hStack.addArrangedSubview(rankLabel)
        hStack.addArrangedSubview(avatarView)
        hStack.addArrangedSubview(vStack)

        contentView.addSubview(hStack)
        hStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.image = nil
        nameLabel.text = nil
        subLabel.text = nil
        rankLabel.text = nil
    }

    func configure(with item: TopArtist) {
        nameLabel.text = item.name
        subLabel.text = item.genres.prefix(2).joined(separator: ", ")
        if let rank = item.rank { rankLabel.text = "\(rank)" }

        if let urlString = item.images.first?.url, let url = URL(string: urlString) {
            avatarView.kf.setImage(with: url)
        } else {
            avatarView.image = UIImage(systemName: "person.crop.square")
            avatarView.tintColor = .systemGray3
        }
    }
}

// MARK: - Safe index extension
private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    let dummyManager = SpotifyStateManager.shared
    let reactor = StatisticsReactor(spotifyStateManager: dummyManager)
    return StatisticsViewController(reactor: reactor)
}
