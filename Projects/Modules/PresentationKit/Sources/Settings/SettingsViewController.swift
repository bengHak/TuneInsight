import SwiftUI
import UIKit
import Then
import SnapKit
import ReactorKit
import RxSwift

public final class SettingsViewController: UIViewController, ReactorKit.View {
    public var disposeBag = DisposeBag()
    public weak var coordinator: SettingsCoordinator?

    private let titleLabel = UILabel().then {
        $0.text = "설정"
        $0.font = .preferredFont(forTextStyle: .largeTitle)
        $0.textAlignment = .center
        $0.textColor = .label
        $0.numberOfLines = 0
        $0.accessibilityIdentifier = "settings_title_label"
    }
    
    private let logoutButton = UIButton(type: .system).then {
        $0.setTitle("로그아웃", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .systemRed
        $0.layer.cornerRadius = 12
        $0.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        $0.accessibilityIdentifier = "logout_button"
    }

    public init(reactor: SettingsReactor = SettingsReactor()) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(logoutButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.leading).offset(24)
            make.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.trailing).inset(24)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
        }
    }

    public func bind(reactor: SettingsReactor) {
        bindActions(reactor)
        bindState(reactor)
    }
    
    private func bindActions(_ reactor: SettingsReactor) {
        // 로그아웃 버튼 탭
        logoutButton.rx.tap
            .map { Reactor.Action.logout }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: SettingsReactor) {
        // 로그아웃 알림 표시
        reactor.state.map { $0.showLogoutAlert }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.showLogoutAlert()
            })
            .disposed(by: disposeBag)
        
        // 로그아웃 완료 처리
        reactor.state.map { $0.isLogoutCompleted }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.didLogout()
            })
            .disposed(by: disposeBag)
        
        // 에러 메시지 표시
        reactor.state.map { $0.errorMessage }
            .distinctUntilChanged()
            .compactMap { $0 }
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

#Preview {
    SettingsViewController()
}