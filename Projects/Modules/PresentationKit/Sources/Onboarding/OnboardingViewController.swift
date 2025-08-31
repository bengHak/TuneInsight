import SwiftUI
import UIKit
import Then
import SnapKit
import ReactorKit
import RxSwift

public final class OnboardingViewController: UIViewController, ReactorKit.View {
    public var disposeBag = DisposeBag()

    private let titleLabel = UILabel().then {
        $0.text = "Onboarding"
        $0.font = .preferredFont(forTextStyle: .largeTitle)
        $0.textAlignment = .center
        $0.textColor = .label
        $0.numberOfLines = 0
        $0.accessibilityIdentifier = "onboarding_title_label"
    }

    public init(reactor: OnboardingReactor = OnboardingReactor()) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.leading).offset(24)
            make.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.trailing).inset(24)
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentSignIn()
    }

    public func bind(reactor: OnboardingReactor) {
        // 기본 바인딩 없음 (최소 화면)
    }
    
    private func presentSignIn() {
        let signInVC = SignInViewController()
        signInVC.modalPresentationStyle = .fullScreen
        self.present(signInVC, animated: true, completion: nil)
    }
}

#Preview {
    OnboardingViewController()
}
