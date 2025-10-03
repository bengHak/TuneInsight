import UIKit
import SafariServices
import Then
import SnapKit
import ReactorKit
import RxSwift
import FoundationKit

public final class SettingsViewController: UIViewController, ReactorKit.View {
    public var disposeBag = DisposeBag()
    public weak var coordinator: SettingsCoordinator?
    
    private enum SettingsItem: CaseIterable {
        case language
        case logout
        case subscription
        case privacy
        
        var title: String {
            switch self {
            case .language:
                return "settings.language".localized()
            case .logout:
                return "settings.logout".localized()
            case .subscription:
                return "settings.subscription".localized()
            case .privacy:
                return "settings.privacyPolicy".localized()
            }
        }
    }

    private let tableView = UITableView(frame: .zero, style: .insetGrouped).then {
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        $0.accessibilityIdentifier = "settings_table_view"
        $0.backgroundColor = CustomColor.background
        $0.tintColor = CustomColor.accent
        $0.separatorColor = CustomColor.separator
    }

    public init(reactor: SettingsReactor = SettingsReactor()) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonDisplayMode = .minimal
        view.backgroundColor = CustomColor.background
        setupUI()
        title = "settings.title".localized()
        reactor?.action.onNext(.viewDidLoad)
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self

        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    public func bind(reactor: SettingsReactor) {
        bindState(reactor)
    }
    
    private func bindState(_ reactor: SettingsReactor) {
        // 로그아웃 알림 표시
        reactor.state.map { $0.showLogoutAlert }
            .distinctUntilChanged()
            .filter { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                self?.showLogoutAlert()
            })
            .disposed(by: disposeBag)
        
        // 로그아웃 완료 처리
        reactor.state.map { $0.isLogoutCompleted }
            .distinctUntilChanged()
            .filter { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.didLogout()
            })
            .disposed(by: disposeBag)
        
        // 에러 메시지 표시
        reactor.state.map { $0.errorMessage }
            .distinctUntilChanged()
            .compactMap { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] error in
                self?.showErrorAlert(message: error)
            })
            .disposed(by: disposeBag)
    }
    
    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: "settings.logout".localized(),
            message: "settings.logoutConfirmMessage".localized(),
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "common.cancel".localized(), style: .cancel)
        let confirmAction = UIAlertAction(title: "common.confirm".localized(), style: .destructive) { [weak self] _ in
            self?.reactor?.action.onNext(.confirmLogout)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "common.error".localized(),
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "common.confirm".localized(), style: .default)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsItem.allCases.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        let item = SettingsItem.allCases[indexPath.row]
        cell.textLabel?.text = item.title
        cell.textLabel?.textColor = CustomColor.primaryText
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = CustomColor.surface
        let selectedView = UIView()
        selectedView.backgroundColor = CustomColor.accentMuted
        selectedView.layer.cornerRadius = 12
        selectedView.layer.masksToBounds = true
        cell.selectedBackgroundView = selectedView
        cell.selectionStyle = .default
        cell.accessoryType = .none
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = SettingsItem.allCases[indexPath.row]
        switch item {
        case .language:
            openLanguageSettings()
        case .logout:
            reactor?.action.onNext(.logout)
        case .subscription:
            coordinator?.showSubscription()
        case .privacy:
            showPrivacyPolicy()
        }
    }
}

private extension SettingsViewController {
    func openLanguageSettings() {
        let alert = UIAlertController(
            title: "settings.language".localized(),
            message: "settings.languageChangePrompt".localized(),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "common.cancel".localized(), style: .cancel))
        alert.addAction(UIAlertAction(title: "settings.openButton".localized(), style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url)
        })
        present(alert, animated: true)
    }
    
    func showPrivacyPolicy() {
        guard let urlString = Bundle.main.infoDictionary?["PRIVACY_POLICY_URL"] as? String,
              let url = URL(string: "https://" + urlString) else {
            print("Invalid privacy policy URL")
            return
        }
        let vc = SFSafariViewController(url: url)
        vc.modalPresentationStyle = .automatic
        present(vc, animated: true)
    }
}
