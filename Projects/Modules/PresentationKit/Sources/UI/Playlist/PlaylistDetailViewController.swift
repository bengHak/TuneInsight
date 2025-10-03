import SwiftUI
import UIKit
import Then
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa
import DomainKit
import Kingfisher
import FoundationKit

public final class PlaylistDetailViewController: UIViewController, ReactorKit.View {
    public var disposeBag = DisposeBag()
    public weak var coordinator: PlaylistDetailCoordinator?

    // MARK: - UI Components

    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
    }

    private let contentView = UIView()

    private let headerView = UIView().then {
        $0.backgroundColor = CustomColor.background
    }

    private let playlistImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.backgroundColor = CustomColor.surfaceElevated
    }

    private let playlistNameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.textColor = CustomColor.primaryText
        $0.numberOfLines = 0
    }

    private let playlistDescriptionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = CustomColor.secondaryText
        $0.numberOfLines = 0
    }

    private let playlistInfoLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = CustomColor.tertiaryText
    }

    private let actionsStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.distribution = .fillEqually
    }

    private let playNextButton = UIButton(type: .system).then {
        $0.setTitle("playlist.playNextButton".localized(), for: .normal)
        $0.setTitleColor(CustomColor.accent, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        $0.backgroundColor = CustomColor.surface
        $0.layer.borderWidth = 1
        $0.layer.borderColor = CustomColor.accent.cgColor
        $0.layer.cornerRadius = 8
        $0.accessibilityIdentifier = "playlist_play_next_button"
    }

    private let addTracksButton = UIButton(type: .system).then {
        $0.setTitle("track.addButton".localized(), for: .normal)
        $0.setTitleColor(CustomColor.background, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        $0.backgroundColor = CustomColor.accent
        $0.layer.cornerRadius = 8
    }

    private let editPlaylistButton = UIButton(type: .system).then {
        $0.setTitle("common.edit".localized(), for: .normal)
        $0.setTitleColor(CustomColor.accent, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        $0.backgroundColor = CustomColor.surface
        $0.layer.borderWidth = 1
        $0.layer.borderColor = CustomColor.accent.cgColor
        $0.layer.cornerRadius = 8
    }

    private let tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        let footerView = UIView()
        footerView.backgroundColor = CustomColor.background
        $0.tableFooterView = footerView
        $0.rowHeight = TrackCell.cellHeight
        $0.register(TrackCell.self, forCellReuseIdentifier: TrackCell.identifier)
        $0.refreshControl = UIRefreshControl()
        $0.isScrollEnabled = false
        $0.accessibilityIdentifier = "playlist_tracks_table"
        $0.backgroundColor = CustomColor.background
        $0.refreshControl?.tintColor = CustomColor.accent
    }

    private let addedDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    private let emptyView = UIView().then {
        $0.isHidden = true
        $0.backgroundColor = CustomColor.background
    }

    private let emptyImageView = UIImageView().then {
        $0.image = UIImage(systemName: "music.note")
        $0.tintColor = CustomColor.secondaryText
        $0.contentMode = .scaleAspectFit
    }

    private let emptyLabel = UILabel().then {
        $0.text = "playlist.noTracks".localized()
        $0.textColor = CustomColor.primaryText
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textAlignment = .center
    }

    private let emptyDescriptionLabel = UILabel().then {
        $0.text = "playlist.emptyTracksHint".localized()
        $0.textColor = CustomColor.secondaryText
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textAlignment = .center
    }

    private let loadingIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.hidesWhenStopped = true
        $0.color = CustomColor.accent
    }

    // MARK: - Properties

    private var tracks: [PlaylistTrack] = []
    private var tableViewHeightConstraint: Constraint?

    // MARK: - Init

    public init(reactor: PlaylistDetailReactor) {
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
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = CustomColor.background
        contentView.backgroundColor = CustomColor.background
        scrollView.backgroundColor = .clear

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(headerView)
        contentView.addSubview(tableView)
        contentView.addSubview(emptyView)
        contentView.addSubview(loadingIndicator)

        headerView.addSubview(playlistImageView)
        headerView.addSubview(playlistNameLabel)
        headerView.addSubview(playlistDescriptionLabel)
        headerView.addSubview(playlistInfoLabel)
        headerView.addSubview(actionsStackView)

        actionsStackView.addArrangedSubview(playNextButton)
        actionsStackView.addArrangedSubview(addTracksButton)
        actionsStackView.addArrangedSubview(editPlaylistButton)

        emptyView.addSubview(emptyImageView)
        emptyView.addSubview(emptyLabel)
        emptyView.addSubview(emptyDescriptionLabel)

        tableView.dataSource = self
        tableView.delegate = self

        setupConstraints()
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        playlistImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(120)
        }

        playlistNameLabel.snp.makeConstraints { make in
            make.top.equalTo(playlistImageView)
            make.leading.equalTo(playlistImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-20)
        }

        playlistDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(playlistNameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(playlistNameLabel)
        }

        playlistInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(playlistDescriptionLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(playlistNameLabel)
        }

        actionsStackView.snp.makeConstraints { make in
            make.top.equalTo(playlistImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-20)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            tableViewHeightConstraint = make.height.equalTo(0).constraint
        }

        emptyView.snp.makeConstraints { make in
            make.top.equalTo(actionsStackView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(40)
        }

        emptyImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(60)
        }

        emptyLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }

        emptyDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(tableView)
        }
    }

    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
    }

    // MARK: - Binding

    public func bind(reactor: PlaylistDetailReactor) {
        // Input
        Observable.just(())
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        tableView.refreshControl?.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        addTracksButton.rx.tap
            .map { Reactor.Action.addTracks }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        editPlaylistButton.rx.tap
            .map { Reactor.Action.editPlaylist }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        playNextButton.rx.tap
            .map { Reactor.Action.queuePlaylistNext }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Output
        reactor.state.map { $0.playlist }
            .distinctUntilChanged { $0?.id == $1?.id }
            .observe(on: MainScheduler.asyncInstance)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] playlist in
                self?.configureHeader(with: playlist)
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.tracks }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] tracks in
                self?.tracks = tracks
                self?.tableView.reloadData()
                self?.updateTableViewHeight()
                self?.emptyView.isHidden = !tracks.isEmpty
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading && self?.tracks.isEmpty == true {
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

        reactor.state.map { $0.infoMessage }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] message in
                self?.showInfoAlert(message: message)
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.shouldShowEditPlaylist }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .filter { $0 }
            .withLatestFrom(reactor.state.map { $0.playlist }.compactMap { $0 })
            .subscribe(onNext: { [weak self] playlist in
                self?.showEditPlaylistAlert(playlist: playlist)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Private Methods

    private func configureHeader(with playlist: Playlist) {
        title = playlist.name
        playlistNameLabel.text = playlist.name
        playlistDescriptionLabel.text = playlist.description?.isEmpty == false ? playlist.description : "common.noDescription".localized()

        let trackCountText = "playlist.trackCountLabel".localizedFormat(playlist.trackCount)
        let ownerText = playlist.owner.displayName
        let visibilityText = playlist.isPublic ? "playlist.visibilityPublic".localized() : "playlist.visibilityPrivate".localized()
        playlistInfoLabel.text = "playlist.detail.summaryFormat".localizedFormat(trackCountText, ownerText, visibilityText)

        if let imageUrl = playlist.imageUrl {
            playlistImageView.kf.setImage(with: URL(string: imageUrl))
        } else {
            playlistImageView.image = UIImage(systemName: "music.note.list")
            playlistImageView.tintColor = .secondaryLabel
        }
    }

    private func updateTableViewHeight() {
        let height = CGFloat(tracks.count) * tableView.rowHeight
        tableViewHeightConstraint?.update(offset: height)

        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "common.error".localized(),
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "common.confirm".localized(), style: .default))
        present(alert, animated: true)
    }

    private func showInfoAlert(message: String) {
        let alert = UIAlertController(
            title: "common.done".localized(),
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "common.confirm".localized(), style: .default))
        present(alert, animated: true)
    }

    private func showEditPlaylistAlert(playlist: Playlist) {
        let alert = UIAlertController(
            title: "playlist.editTitle".localized(),
            message: "playlist.editPrompt".localized(),
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "playlist.nameLabel".localized()
            textField.text = playlist.name
            textField.autocapitalizationType = .words
        }

        alert.addTextField { textField in
            textField.placeholder = "common.descriptionOptional".localized()
            textField.text = playlist.description
        }

        let saveAction = UIAlertAction(title: "common.save".localized(), style: .default) { [weak self, weak alert] _ in
            guard let nameField = alert?.textFields?[0],
                  let descriptionField = alert?.textFields?[1],
                  let name = nameField.text, !name.isEmpty else { return }

            let description = descriptionField.text?.isEmpty == false ? descriptionField.text : nil
            self?.reactor?.action.onNext(.updatePlaylist(name: name, description: description, isPublic: playlist.isPublic))
        }

        alert.addAction(UIAlertAction(title: "common.cancel".localized(), style: .cancel))
        alert.addAction(saveAction)

        present(alert, animated: true)
    }

    private func showDeleteTrackConfirmation(for track: PlaylistTrack) {
        let alert = UIAlertController(
            title: "playlist.deleteTrackTitle".localized(),
            message: "playlist.removeTrack.confirmMessage".localizedFormat(track.name),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "common.cancel".localized(), style: .cancel))
        alert.addAction(UIAlertAction(title: "common.delete".localized(), style: .destructive) { [weak self] _ in
            self?.reactor?.action.onNext(.deleteTrack(track))
        })

        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension PlaylistDetailViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TrackCell.identifier,
            for: indexPath
        ) as? TrackCell else {
            return UITableViewCell()
        }

        let track = tracks[indexPath.row]
        cell.configure(with: makeTrackViewModel(from: track))

        return cell
    }
}

// MARK: - UITableViewDelegate

extension PlaylistDetailViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let track = tracks[indexPath.row]
        reactor?.action.onNext(.selectTrack(track))
    }

    public func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let track = tracks[indexPath.row]

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "common.delete".localized()
        ) { [weak self] _, _, completionHandler in
            self?.showDeleteTrackConfirmation(for: track)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .systemRed

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false

        return configuration
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let height = scrollView.frame.size.height

            if offsetY > contentHeight - height - 100 {
                reactor?.action.onNext(.loadMore)
            }
        }
    }
}

private extension PlaylistDetailViewController {
    func makeTrackViewModel(from track: PlaylistTrack) -> TrackCell.ViewModel {
        let artworkURL = track.albumImageUrl.flatMap(URL.init)
        let addedDate = track.addedAt.map { addedDateFormatter.string(from: $0) }

        return TrackCell.ViewModel(
            titleText: track.name,
            artistText: track.artistsText,
            albumText: track.album,
            playedAtText: addedDate,
            durationText: track.formattedDuration,
            rankText: nil,
            artworkURL: artworkURL
        )
    }
}
