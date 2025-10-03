import SwiftUI
import UIKit
import Then
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa
import DomainKit

public final class TrackSearchViewController: UIViewController, ReactorKit.View {
    public var disposeBag = DisposeBag()
    public weak var coordinator: TrackSearchCoordinator?

    // MARK: - UI Components

    private let searchController = UISearchController(searchResultsController: nil).then {
        $0.searchBar.placeholder = "트랙 검색"
        $0.searchBar.searchBarStyle = .minimal
        $0.obscuresBackgroundDuringPresentation = false
        $0.hidesNavigationBarDuringPresentation = false
    }

    private let tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .singleLine
        $0.tableFooterView = UIView()
        $0.rowHeight = 72
        $0.register(TrackSearchCell.self, forCellReuseIdentifier: TrackSearchCell.identifier)
        $0.keyboardDismissMode = .onDrag
        $0.accessibilityIdentifier = "track_search_table"
    }

    private let emptyStateView = UIView().then {
        $0.isHidden = true
    }

    private let emptyImageView = UIImageView().then {
        $0.image = UIImage(systemName: "magnifyingglass")
        $0.tintColor = .secondaryLabel
        $0.contentMode = .scaleAspectFit
    }

    private let emptyTitleLabel = UILabel().then {
        $0.text = "트랙 검색"
        $0.textColor = .secondaryLabel
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
        $0.textAlignment = .center
    }

    private let emptyDescriptionLabel = UILabel().then {
        $0.text = "플레이리스트에 추가할 트랙을 검색해보세요"
        $0.textColor = .tertiaryLabel
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }

    private let noResultsView = UIView().then {
        $0.isHidden = true
    }

    private let noResultsImageView = UIImageView().then {
        $0.image = UIImage(systemName: "music.note.list")
        $0.tintColor = .secondaryLabel
        $0.contentMode = .scaleAspectFit
    }

    private let noResultsLabel = UILabel().then {
        $0.text = "검색 결과가 없습니다"
        $0.textColor = .secondaryLabel
        $0.font = .systemFont(ofSize: 18, weight: .medium)
        $0.textAlignment = .center
    }

    private let loadingIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.hidesWhenStopped = true
    }

    private let addButton = UIButton(type: .system).then {
        $0.setTitle("플레이리스트에 추가", for: .normal)
        $0.setTitleColor(CustomColor.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.backgroundColor = CustomColor.systemBlue
        $0.layer.cornerRadius = 25
        $0.layer.shadowColor = CustomColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 4
        $0.layer.shadowOpacity = 0.1
        $0.isHidden = true
    }

    private let addButtonCountLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.backgroundColor = .systemRed
        $0.textAlignment = .center
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        $0.isHidden = true
    }

    // MARK: - Properties

    private var searchResults: [SearchTrackResult] = []
    private let playlist: Playlist

    // MARK: - Init

    public init(reactor: TrackSearchReactor, playlist: Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.searchBar.becomeFirstResponder()
    }

    // MARK: - Setup

    private func setupUI() {
        title = "트랙 검색"
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(noResultsView)
        view.addSubview(loadingIndicator)
        view.addSubview(addButton)
        view.addSubview(addButtonCountLabel)

        emptyStateView.addSubview(emptyImageView)
        emptyStateView.addSubview(emptyTitleLabel)
        emptyStateView.addSubview(emptyDescriptionLabel)

        noResultsView.addSubview(noResultsImageView)
        noResultsView.addSubview(noResultsLabel)

        tableView.dataSource = self
        tableView.delegate = self

        setupConstraints()
    }

    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        emptyStateView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
        }

        emptyImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(80)
        }

        emptyTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
        }

        emptyDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        noResultsView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
        }

        noResultsImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(60)
        }

        noResultsLabel.snp.makeConstraints { make in
            make.top.equalTo(noResultsImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        addButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        addButtonCountLabel.snp.makeConstraints { make in
            make.trailing.equalTo(addButton.snp.trailing).offset(-12)
            make.top.equalTo(addButton.snp.top).offset(-8)
            make.size.equalTo(20)
        }
    }

    private func setupNavigationBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        let cancelButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: nil,
            action: nil
        )
        navigationItem.rightBarButtonItem = cancelButton
    }

    // MARK: - Binding

    public func bind(reactor: TrackSearchReactor) {
        // Input
        searchController.searchBar.rx.text
            .orEmpty
            .distinctUntilChanged()
            .map { Reactor.Action.updateSearchText($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        searchController.searchBar.rx.text
            .orEmpty
            .distinctUntilChanged()
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .map { Reactor.Action.search($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        navigationItem.rightBarButtonItem?.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.finishTrackSearch()
            })
            .disposed(by: disposeBag)

        addButton.rx.tap
            .map { Reactor.Action.addSelectedTracksToPlaylist }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Output
        reactor.state.map { $0.searchResults }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] results in
                self?.searchResults = results
                self?.tableView.reloadData()
                self?.updateEmptyStates(results: results, searchText: reactor.currentState.searchText)
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                    self?.hideEmptyStates()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.selectedTracksCount }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] count in
                self?.updateAddButton(count: count)
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

        reactor.state.map { $0.successMessage }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] successMessage in
                self?.showSuccessAlert(message: successMessage)
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.isAddingTracks }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] isAdding in
                self?.addButton.isEnabled = !isAdding
                if isAdding {
                    self?.addButton.setTitle("추가 중...", for: .normal)
                } else {
                    self?.addButton.setTitle("플레이리스트에 추가", for: .normal)
                }
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Private Methods

    private func updateEmptyStates(results: [SearchTrackResult], searchText: String) {
        let isEmpty = results.isEmpty
        let hasSearchText = !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        if hasSearchText && isEmpty {
            // Show no results state
            emptyStateView.isHidden = true
            noResultsView.isHidden = false
        } else if !hasSearchText {
            // Show initial empty state
            emptyStateView.isHidden = false
            noResultsView.isHidden = true
        } else {
            // Hide all empty states
            hideEmptyStates()
        }
    }

    private func hideEmptyStates() {
        emptyStateView.isHidden = true
        noResultsView.isHidden = true
    }

    private func updateAddButton(count: Int) {
        let shouldShow = count > 0

        UIView.animate(withDuration: 0.3) {
            self.addButton.isHidden = !shouldShow
            self.addButtonCountLabel.isHidden = !shouldShow
        }

        if shouldShow {
            addButtonCountLabel.text = "\(count)"
        }
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(
            title: "완료",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension TrackSearchViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: TrackSearchCell.identifier,
            for: indexPath
        ) as! TrackSearchCell

        let track = searchResults[indexPath.row]
        let isSelected = reactor?.currentState.selectedTrackIds.contains(track.id) ?? false

        cell.configure(with: track, isSelected: isSelected)
        cell.onSelectionChanged = { [weak self] track, isSelected in
            if isSelected {
                self?.reactor?.action.onNext(.selectTrack(track))
            } else {
                self?.reactor?.action.onNext(.deselectTrack(track))
            }
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension TrackSearchViewController: UITableViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height - 100 {
            reactor?.action.onNext(.loadMore)
        }
    }
}