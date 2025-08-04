//  HomeViewController.swift
//  SpotifyStats
import UIKit

final class HomeViewController: UIViewController {

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "SpotifyStats (UIKit)"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "UINavigationController + UIViewController 기반 스타터 화면"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .equalSpacing
        return sv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(stackView)
        [titleLabel, descriptionLabel].forEach(stackView.addArrangedSubview)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

#Preview {
    let homeVC = HomeViewController()
    homeVC.title = "SpotifyStats"
    let navigationController = UINavigationController(rootViewController: homeVC)
    navigationController.navigationBar.prefersLargeTitles = true
    return navigationController
}
