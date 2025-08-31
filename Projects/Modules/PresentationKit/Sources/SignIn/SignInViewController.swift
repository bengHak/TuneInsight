//
//  SignInViewController.swift
//  PresentationKit
//
//  Created by 고병학 on 8/14/25.
//  Copyright © 2025 Sparkish. All rights reserved.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import SpotifyiOS
import ThirdPartyManager

public final class SignInViewController: UIViewController {
    
	private let titleLabel = UILabel().then {
		$0.text = "Sign in with Spotify"
		$0.font = .preferredFont(forTextStyle: .title1)
		$0.textAlignment = .center
		$0.numberOfLines = 0
	}
	private let loginButton = UIButton(type: .system).then {
		$0.setTitle("Continue with Spotify", for: .normal)
		$0.titleLabel?.font = .preferredFont(forTextStyle: .headline)
		$0.backgroundColor = UIColor(red: 30/255, green: 215/255, blue: 96/255, alpha: 1)
		$0.setTitleColor(.black, for: .normal)
		$0.layer.cornerRadius = 12
		$0.accessibilityIdentifier = "spotify_login_button"
	}
    
    private let disposeBag = DisposeBag()
    public weak var coordinator: SignInCoordinator?

	public override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		layout()
		bind()
	}

	private func layout() {
		view.addSubview(titleLabel)
		view.addSubview(loginButton)
		titleLabel.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview().offset(-40)
			make.leading.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.leading).offset(24)
			make.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.trailing).inset(24)
		}
		loginButton.snp.makeConstraints { make in
			make.top.equalTo(titleLabel.snp.bottom).offset(32)
			make.centerX.equalToSuperview()
			make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(40)
			make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(40)
			make.height.equalTo(54)
		}
	}

	private func bind() {
		loginButton.rx.tap
			.throttle(.milliseconds(500), scheduler: MainScheduler.instance)
			.bind(onNext: { [weak self] in
				guard let self else { return }
				SpotifyAuthManager.shared.startAuthorization(from: self)
			})
			.disposed(by: disposeBag)
        
		SpotifyAuthManager.shared.authorizationState
			.observe(on: MainScheduler.asyncInstance)
			.subscribe(onNext: { [weak self] state in
                guard let self else { return }
				switch state {
				case let .failed(error):
                    self.showAlert(error)
                case let .authorized(session):
                    self.handleToken(
                        accessToken: session.accessToken,
                        refreshToken: session.refreshToken,
                        expirationDate: session.expirationDate
                    )
                case .idle, .authorizing:
					break
				}
			})
			.disposed(by: disposeBag)
	}
    
    private func showAlert(_ error: Error) {
        let alert = UIAlertController(
            title: "Spotify Auth Failed",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )
        self.present(alert, animated: true)
    }
    
    private func handleToken(
        accessToken: String,
        refreshToken: String,
        expirationDate: Date
    ) {
        // reactor에서 처리
    }
}

#Preview {
	SignInViewController()
}
