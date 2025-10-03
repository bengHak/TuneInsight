import UIKit
import Then
import SnapKit
import RevenueCat

public final class SubscriptionViewController: UIViewController {
    private let statusTitleLabel = UILabel().then {
        $0.text = "구독 상태"
        $0.font = .preferredFont(forTextStyle: .largeTitle)
        $0.textAlignment = .left
        $0.textColor = .label
        $0.numberOfLines = 1
        $0.accessibilityIdentifier = "subscription_title_label"
    }

    private let statusLabel = UILabel().then {
        $0.text = "구독 상태 확인 중..."
        $0.font = .preferredFont(forTextStyle: .body)
        $0.textAlignment = .left
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 0
        $0.accessibilityIdentifier = "subscription_status_label"
    }

    private let refreshButton = UIButton(type: .system).then {
        $0.setTitle("새로고침", for: .normal)
        $0.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        $0.accessibilityIdentifier = "subscription_refresh_button"
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "구독관리"
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
        statusLabel.text = "구독 상태 확인 중..."
        Purchases.shared.getCustomerInfo { [weak self] info, error in
            guard let self = self else { return }
            if let error = error {
                self.statusLabel.text = "오류: \(error.localizedDescription)"
                self.statusLabel.textColor = .systemRed
                return
            }

            guard let info = info else {
                self.statusLabel.text = "구독 정보를 불러올 수 없습니다."
                self.statusLabel.textColor = .systemRed
                return
            }

            let active = info.entitlements.active
            if active.isEmpty {
                self.statusLabel.text = "구독 중이 아닙니다."
                self.statusLabel.textColor = .label
            } else {
                // 임의로 첫 번째 활성 엔타이틀먼트를 표시
                if let first = active.first {
                    var details: [String] = []
                    details.append("Entitlement: \(first.key)")
                    if let exp = first.value.expirationDate {
                        let formatter = DateFormatter()
                        formatter.dateStyle = .medium
                        formatter.timeStyle = .short
                        details.append("만료: \(formatter.string(from: exp))")
                    }
                    self.statusLabel.text = (["구독 중"] + details).joined(separator: "\n")
                } else {
                    self.statusLabel.text = "구독 중"
                }
                self.statusLabel.textColor = .label
            }
        }
    }
}

