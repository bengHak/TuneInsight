import UIKit
import Then
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa
import PresentationKit

final class SplashViewController: UIViewController, View {
    var disposeBag = DisposeBag()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let titleLabel = UILabel().then {
        $0.text = "SpotifyStats"
        $0.font = .preferredFont(forTextStyle: .largeTitle)
        $0.textAlignment = .center
        $0.textColor = .label
    }

    init(reactor: SplashViewReactor = SplashViewReactor()) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(titleLabel)
        view.addSubview(activityIndicator)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-24)
            make.leading.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.leading).offset(24)
            make.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.trailing).inset(24)
        }
        activityIndicator.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reactor?.action.onNext(.viewDidAppear)
    }

    func bind(reactor: SplashViewReactor) {
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] loading in
                loading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            })
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.shouldRouteToOnboarding }
            .distinctUntilChanged()
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] _ in
                self?.routeToOnboarding()
            })
            .disposed(by: disposeBag)
    }

    private func routeToOnboarding() {
        let onboardingVC = OnboardingViewController()
        guard let navigationController = self.navigationController else {
            // 네비게이션 컨텍스트가 없으면 rootViewController 자체를 교체
            view.window?.rootViewController = UINavigationController(rootViewController: onboardingVC)
            view.window?.makeKeyAndVisible()
            return
        }
        // 네비게이션 컨트롤러의 루트뷰를 Onboarding으로 교체
        navigationController.setViewControllers([onboardingVC], animated: false)
    }
}

#Preview {
    SplashViewController()
}
