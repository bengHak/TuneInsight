import SwiftUI
import UIKit
import Then
import SnapKit
import ReactorKit
import RxSwift

public final class OnboardingViewController: UIViewController, ReactorKit.View {
    public var disposeBag = DisposeBag()
    public weak var coordinator: OnboardingCoordinator?

    private let titleLabel = UILabel().then {
        $0.text = "Onboarding"
        $0.font = .preferredFont(forTextStyle: .largeTitle)
        $0.textAlignment = .center
        $0.textColor = .label
        $0.numberOfLines = 0
        $0.accessibilityIdentifier = "onboarding_title_label"
    }
    
    private let nextButton = UIButton(type: .system).then {
        $0.setTitle("다음", for: .normal)
        $0.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        $0.backgroundColor = UIColor.systemBlue
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 12
        $0.accessibilityIdentifier = "onboarding_next_button"
    }

    public init(reactor: OnboardingReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reactor?.action.onNext(.checkAuthentication)
        print(#function)
    }
    
    private func configureSubviews() {
        view.backgroundColor = .systemBackground

        view.addSubview(titleLabel)
        view.addSubview(nextButton)
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.leading).offset(24)
            make.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.trailing).inset(24)
        }
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(40)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(24)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(24)
            make.height.equalTo(54)
        }
    }

    public func bind(reactor: OnboardingReactor) {
        nextButton.rx.tap
            .map { OnboardingReactor.Action.nextButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.shouldShowSignIn }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.showSignIn()
            })
            .disposed(by: disposeBag)
    }
}

#Preview {
    OnboardingViewController(reactor: OnboardingReactor())
}
