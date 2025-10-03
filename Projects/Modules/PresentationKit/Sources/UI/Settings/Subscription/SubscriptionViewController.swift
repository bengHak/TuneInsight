import UIKit
import Then
import SnapKit
import RevenueCat
import FoundationKit

public final class SubscriptionViewController: UIViewController {
    private let statusTitleLabel = UILabel().then {
        $0.text = "subscription.statusTitle".localized()
        $0.font = .preferredFont(forTextStyle: .largeTitle)
        $0.textAlignment = .left
        $0.textColor = CustomColor.primaryText
        $0.numberOfLines = 1
        $0.accessibilityIdentifier = "subscription_title_label"
    }

    private let statusLabel = UILabel().then {
        $0.text = "subscription.statusLoading".localized()
        $0.font = .preferredFont(forTextStyle: .body)
        $0.textAlignment = .left
        $0.textColor = CustomColor.secondaryText
        $0.numberOfLines = 0
        $0.accessibilityIdentifier = "subscription_status_label"
    }

    private let refreshButton = UIButton(type: .system).then {
        $0.setTitle("common.refresh".localized(), for: .normal)
        $0.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        $0.backgroundColor = CustomColor.accent
        $0.setTitleColor(CustomColor.background, for: .normal)
        $0.layer.cornerRadius = 12
        $0.accessibilityIdentifier = "subscription_refresh_button"
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonDisplayMode = .minimal
        view.backgroundColor = CustomColor.background
        title = "settings.subscription".localized()
        setupUI()
        bind()
        fetchCustomerInfo()
    }

    private func setupUI() {
        view.addSubview(statusTitleLabel)
        view.addSubview(statusLabel)
        view.addSubview(refreshButton)

        statusTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(statusTitleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        refreshButton.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
    }

    private func bind() {
        refreshButton.addTarget(self, action: #selector(onTapRefresh), for: .touchUpInside)
    }

    @objc private func onTapRefresh() {
        fetchCustomerInfo()
    }

    private func fetchCustomerInfo() {
        statusLabel.text = "subscription.statusLoading".localized()
        Purchases.shared.getCustomerInfo { [weak self] info, error in
            guard let self = self else { return }
            if let error = error {
                self.statusLabel.text = "error.withDetail".localizedFormat(error.localizedDescription)
                self.statusLabel.textColor = .systemRed
                return
            }

            guard let info = info else {
                self.statusLabel.text = "subscription.statusUnavailable".localized()
                self.statusLabel.textColor = .systemRed
                return
            }

            let active = info.entitlements.active
            if active.isEmpty {
                self.statusLabel.text = "subscription.inactive".localized()
                self.statusLabel.textColor = CustomColor.primaryText
            } else {
                // 임의로 첫 번째 활성 엔타이틀먼트를 표시
                if let first = active.first {
                    var details: [String] = []
                    details.append("subscription.entitlementNameFormat".localizedFormat(first.key))
                    if let exp = first.value.expirationDate {
                        let formatter = DateFormatter()
                        formatter.dateStyle = .medium
                        formatter.timeStyle = .short
                        details.append("subscription.expirationFormat".localizedFormat(formatter.string(from: exp)))
                    }
                    self.statusLabel.text = (["subscription.active".localized()] + details).joined(separator: "\n")
                } else {
                    self.statusLabel.text = "subscription.active".localized()
                }
                self.statusLabel.textColor = CustomColor.primaryText
            }
        }
    }
}
