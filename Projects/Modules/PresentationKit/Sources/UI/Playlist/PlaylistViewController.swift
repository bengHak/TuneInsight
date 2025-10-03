import SwiftUI
import UIKit
import Then
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa
import DomainKit
import Kingfisher

public final class PlaylistViewController: UIViewController, ReactorKit.View {
    public var disposeBag = DisposeBag()
    public weak var coordinator: PlaylistCoordinator?

    // MARK: - UI Components

    private let tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .singleLine
        let footerView = UIView()
        footerView.backgroundColor = CustomColor.background
        $0.tableFooterView = footerView
        $0.rowHeight = 72
        $0.register(PlaylistListCell.self, forCellReuseIdentifier: PlaylistListCell.identifier)
        $0.refreshControl = UIRefreshControl()
        $0.accessibilityIdentifier = "playlist_list_table"
        $0.backgroundColor = CustomColor.background
        $0.separatorColor = CustomColor.separator
        $0.refreshControl?.tintColor = CustomColor.accent
    }

    private let emptyView = UIView().then {
        $0.isHidden = true
        $0.backgroundColor = CustomColor.background
    }

    private let emptyImageView = UIImageView().then {
        $0.image = UIImage(systemName: "music.note.list")
        $0.tintColor = CustomColor.secondaryText
        $0.contentMode = .scaleAspectFit
    }

    private let emptyLabel = UILabel().then {
        $0.text = "플레이리스트가 없습니다"
        $0.textColor = CustomColor.primaryText
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textAlignment = .center
    }

    private let emptyDescriptionLabel = UILabel().then {
        $0.text = "새로운 플레이리스트를 만들어보세요"
        $0.textColor = CustomColor.secondaryText
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textAlignment = .center
    }

    private let loadingIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.hidesWhenStopped = true
        $0.color = CustomColor.accent
    }

    // MARK: - Properties

    private var playlists: [Playlist] = []

    // MARK: - Init

    public init(reactor: PlaylistListReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonDisplayMode = .minimal
        setupUI()
        setupNavigationBar()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        reactor?.action.onNext(.viewWillAppear)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    // MARK: - Setup

    private func setupUI() {
        title = "플레이리스트"
        view.backgroundColor = CustomColor.background

        view.addSubview(tableView)
        view.addSubview(emptyView)
        view.addSubview(loadingIndicator)

        emptyView.addSubview(emptyImageView)
        emptyView.addSubview(emptyLabel)
        emptyView.addSubview(emptyDescriptionLabel)

        tableView.dataSource = self
        tableView.delegate = self

        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        emptyView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
        }

        emptyImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(80)
        }

        emptyLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
        }

        emptyDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: nil,
            action: nil
        )
        addButton.tintColor = CustomColor.accent
        navigationItem.rightBarButtonItem = addButton
        
        guard let reactor else { return }
        addButton.rx.tap
            .map { Reactor.Action.createPlaylist }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    // MARK: - Binding

    public func bind(reactor: PlaylistListReactor) {
        // Input
        Observable.just(())
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        tableView.refreshControl?.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Output
        reactor.state.map { $0.playlists }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] playlists in
                self?.playlists = playlists
                self?.tableView.reloadData()
                self?.emptyView.isHidden = !playlists.isEmpty
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading && self?.playlists.isEmpty == true {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.isRefreshing }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] isRefreshing in
                if !isRefreshing {
                    self?.tableView.refreshControl?.endRefreshing()
                }
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.errorMessage }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] errorMessage in
                self?.showErrorAlert(message: errorMessage)
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.shouldShowCreatePlaylist }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .compactMap { $0 }
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.showCreatePlaylist()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Private Methods

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }


    private func showDeleteConfirmation(for playlist: Playlist) {
        let alert = UIAlertController(
            title: "플레이리스트 삭제",
            message: "'\(playlist.name)'을(를) 삭제하시겠습니까?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.reactor?.action.onNext(.deletePlaylist(playlist))
        })

        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension PlaylistViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: PlaylistListCell.identifier,
            for: indexPath
        ) as! PlaylistListCell

        let playlist = playlists[indexPath.row]
        cell.configure(with: playlist)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension PlaylistViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let playlist = playlists[indexPath.row]
        reactor?.action.onNext(.selectPlaylist(playlist))
    }

    public func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let playlist = playlists[indexPath.row]

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "삭제"
        ) { [weak self] _, _, completionHandler in
            self?.showDeleteConfirmation(for: playlist)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .systemRed

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false

        return configuration
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height - 100 {
            reactor?.action.onNext(.loadMore)
        }
    }
}
