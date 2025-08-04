//  HomeViewController.swift
//  SpotifyStats
import UIKit
import Then
import SnapKit

final class HomeViewController: UIViewController {

    // MARK: - UI

    private let titleLabel = UILabel().then {
        $0.text = "SpotifyStats (UIKit)"
        $0.font = .preferredFont(forTextStyle: .title2)
        $0.adjustsFontForContentSizeCategory = true
        $0.textColor = .label
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }

    private let descriptionLabel = UILabel().then {
        $0.text = "UINavigationController + UIViewController 기반 스타터 화면"
        $0.font = .preferredFont(forTextStyle: .body)
        $0.adjustsFontForContentSizeCategory = true
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private let actionButton = UIButton(type: .system).then {
        var config = UIButton.Configuration.filled()
        config.title = "Action"
        config.titleAlignment = .center
        config.baseForegroundColor = .label
        config.baseBackgroundColor = .tertiarySystemBackground
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        $0.configuration = config
        $0.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        $0.titleLabel?.adjustsFontForContentSizeCategory = true
        $0.accessibilityIdentifier = "home_action_button"
    }

    private let containerView = UIView().then {
        $0.backgroundColor = .secondarySystemBackground
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.isAccessibilityElement = true
        $0.accessibilityLabel = "container"
    }

    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .fill
        $0.distribution = .equalSpacing
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        setupConstraints()
        bindActions()
    }

    // MARK: - Setup

    private func setupViews() {
        view.addSubview(containerView)
        containerView.addSubview(stackView)
        [titleLabel, descriptionLabel, actionButton].forEach { stackView.addArrangedSubview($0) }
    }

    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(24)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(24)
            make.centerY.equalTo(view.snp.centerY)
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    private func bindActions() {
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc
    private func didTapActionButton() {
        // 기존 기능/데이터 바인딩이 있다면 이 안에 유지/호출
        let alert = UIAlertController(title: "Action", message: "Button tapped", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

#Preview {
    let homeVC = HomeViewController()
    homeVC.title = "SpotifyStats"
    let navigationController = UINavigationController(rootViewController: homeVC)
    navigationController.navigationBar.prefersLargeTitles = true
    return navigationController
}
