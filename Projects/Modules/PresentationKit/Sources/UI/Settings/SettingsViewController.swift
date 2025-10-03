import UIKit
import SafariServices
import Then
import SnapKit
import ReactorKit
import RxSwift

public final class SettingsViewController: UIViewController, ReactorKit.View {
    public var disposeBag = DisposeBag()
    public weak var coordinator: SettingsCoordinator?
    
    private enum SettingsItem: String, CaseIterable {
        case logout = "로그아웃"
        case subscription = "구독관리"
        case privacy = "개인정보처리방침"
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
        title = "설정"
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
            title: "로그아웃",
            message: "정말로 로그아웃 하시겠습니까?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let confirmAction = UIAlertAction(title: "확인", style: .destructive) { [weak self] _ in
            self?.reactor?.action.onNext(.confirmLogout)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "확인", style: .default)
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
        cell.textLabel?.text = item.rawValue
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
