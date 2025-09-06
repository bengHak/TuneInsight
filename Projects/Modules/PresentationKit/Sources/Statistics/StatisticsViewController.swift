import SwiftUI
import UIKit
import Then
import SnapKit
import ReactorKit
import RxSwift

public final class StatisticsViewController: UIViewController, ReactorKit.View {
    public var disposeBag = DisposeBag()
    public weak var coordinator: StatisticsCoordinator?

    private let titleLabel = UILabel().then {
        $0.text = "통계"
        $0.font = .preferredFont(forTextStyle: .largeTitle)
        $0.textAlignment = .center
        $0.textColor = .label
        $0.numberOfLines = 0
        $0.accessibilityIdentifier = "statistics_title_label"
    }

    public init(reactor: StatisticsReactor = StatisticsReactor()) {
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

    public func bind(reactor: StatisticsReactor) {
        // 기본 바인딩 없음 (최소 화면)
    }
}

#Preview {
    StatisticsViewController()
}