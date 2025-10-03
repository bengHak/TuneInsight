import UIKit
import Then
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa

public final class SplashViewController: UIViewController, ReactorKit.View {
    public typealias Reactor = SplashViewReactor

    public var disposeBag = DisposeBag()
    public weak var coordinator: SplashCoordinator?

    private let activityIndicator = UIActivityIndicatorView(style: .large).then {
        $0.color = CustomColor.spotifyGreen
    }

    private let titleLabel = UILabel().then {
        $0.text = "SpotifyStats"
        $0.font = .preferredFont(forTextStyle: .largeTitle)
        $0.textAlignment = .center
        $0.textColor = CustomColor.primaryText
    }

    public init(reactor: SplashViewReactor = SplashViewReactor()) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonDisplayMode = .minimal
        view.backgroundColor = CustomColor.background

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

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reactor?.action.onNext(.viewDidAppear)
    }

    public func bind(reactor: SplashViewReactor) {
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] loading in
                guard let self else { return }
                loading ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
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
        coordinator?.routeToOnboarding()
    }
}

#Preview {
    SplashViewController()
}
