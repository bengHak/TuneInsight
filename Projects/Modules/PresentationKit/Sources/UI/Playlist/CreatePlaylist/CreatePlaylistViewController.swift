import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import SnapKit
import Then

public final class CreatePlaylistViewController: UIViewController, ReactorKit.View {
    public var disposeBag = DisposeBag()
    public weak var coordinator: CreatePlaylistCoordinator?

    // MARK: - UI Components

    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.keyboardDismissMode = .onDrag
    }

    private let contentView = UIView()

    private let headerView = UIView().then {
        $0.backgroundColor = .systemBackground
    }

    private let titleLabel = UILabel().then {
        $0.text = "새 플레이리스트"
        $0.font = .systemFont(ofSize: 28, weight: .bold)
        $0.textColor = .label
    }

    private let subtitleLabel = UILabel().then {
        $0.text = "나만의 플레이리스트를 만들어보세요"
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = .secondaryLabel
    }

    private let formStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 24
        $0.distribution = .fill
    }

    // Name Section
    private let nameSection = UIView()
    private let nameLabel = UILabel().then {
        $0.text = "플레이리스트 이름 *"
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = .label
    }

    private let nameTextField = UITextField().then {
        $0.placeholder = "플레이리스트 이름을 입력하세요"
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.borderStyle = .roundedRect
        $0.backgroundColor = .secondarySystemBackground
        $0.clearButtonMode = .whileEditing
        $0.autocapitalizationType = .words
        $0.returnKeyType = .next
    }

    private let nameErrorLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .systemRed
        $0.isHidden = true
    }

    // Description Section
    private let descriptionSection = UIView()
    private let descriptionLabel = UILabel().then {
        $0.text = "설명"
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = .label
    }

    private let descriptionTextView = UITextView().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.backgroundColor = .secondarySystemBackground
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = CustomColor.separator.cgColor
        $0.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        $0.isScrollEnabled = false
        $0.returnKeyType = .default
    }

    private let descriptionPlaceholderLabel = UILabel().then {
        $0.text = "플레이리스트에 대한 설명을 작성하세요 (선택사항)"
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = .placeholderText
    }

    // Settings Section
    private let settingsSection = UIView()
    private let settingsLabel = UILabel().then {
        $0.text = "설정"
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = .label
    }

    private let publicToggleView = UIView()
    private let publicLabel = UILabel().then {
        $0.text = "공개 플레이리스트"
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = .label
    }

    private let publicDescriptionLabel = UILabel().then {
        $0.text = "다른 사용자들이 플레이리스트를 볼 수 있습니다"
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 0
    }

    private let publicSwitch = UISwitch().then {
        $0.isOn = true
    }

    private let collaborativeToggleView = UIView()
    private let collaborativeLabel = UILabel().then {
        $0.text = "협업 플레이리스트"
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = .label
    }

    private let collaborativeDescriptionLabel = UILabel().then {
        $0.text = "다른 사용자들이 플레이리스트에 트랙을 추가할 수 있습니다"
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 0
    }

    private let collaborativeSwitch = UISwitch().then {
        $0.isOn = false
    }

    // Create Button
    private let createButton = UIButton(type: .system).then {
        $0.setTitle("플레이리스트 생성", for: .normal)
        $0.setTitleColor(CustomColor.white, for: .normal)
        $0.setTitleColor(CustomColor.white60, for: .disabled)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.backgroundColor = CustomColor.systemBlue
        $0.layer.cornerRadius = 12
        $0.isEnabled = false
    }

    private let loadingIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.hidesWhenStopped = true
        $0.color = .white
    }

    // MARK: - Init

    public init(reactor: CreatePlaylistReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonDisplayMode = .minimal
        setupUI()
        setupNavigationBar()
        setupKeyboardHandling()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nameTextField.becomeFirstResponder()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(headerView)
        contentView.addSubview(formStackView)
        contentView.addSubview(createButton)

        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)

        // Name Section
        nameSection.addSubview(nameLabel)
        nameSection.addSubview(nameTextField)
        nameSection.addSubview(nameErrorLabel)

        // Description Section
        descriptionSection.addSubview(descriptionLabel)
        descriptionSection.addSubview(descriptionTextView)
        descriptionTextView.addSubview(descriptionPlaceholderLabel)

        // Settings Section
        settingsSection.addSubview(settingsLabel)
        settingsSection.addSubview(publicToggleView)
        settingsSection.addSubview(collaborativeToggleView)

        publicToggleView.addSubview(publicLabel)
        publicToggleView.addSubview(publicDescriptionLabel)
        publicToggleView.addSubview(publicSwitch)

        collaborativeToggleView.addSubview(collaborativeLabel)
        collaborativeToggleView.addSubview(collaborativeDescriptionLabel)
        collaborativeToggleView.addSubview(collaborativeSwitch)

        formStackView.addArrangedSubview(nameSection)
        formStackView.addArrangedSubview(descriptionSection)
        formStackView.addArrangedSubview(settingsSection)

        createButton.addSubview(loadingIndicator)

        setupConstraints()
        setupTextViewDelegate()
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }

        formStackView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // Name Section
        nameLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }

        nameErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        // Description Section
        descriptionLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(100)
        }

        descriptionPlaceholderLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextView.textContainerInset.top)
            make.leading.equalTo(descriptionTextView.textContainerInset.left + 4)
            make.trailing.equalTo(-descriptionTextView.textContainerInset.right)
        }

        // Settings Section
        settingsLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        publicToggleView.snp.makeConstraints { make in
            make.top.equalTo(settingsLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
        }

        publicLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.trailing.equalTo(publicSwitch.snp.leading).offset(-16)
        }

        publicDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(publicLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview()
            make.trailing.equalTo(publicSwitch.snp.leading).offset(-16)
            make.bottom.equalToSuperview()
        }

        publicSwitch.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
        }

        collaborativeToggleView.snp.makeConstraints { make in
            make.top.equalTo(publicToggleView.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }

        collaborativeLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.trailing.equalTo(collaborativeSwitch.snp.leading).offset(-16)
        }

        collaborativeDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(collaborativeLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview()
            make.trailing.equalTo(collaborativeSwitch.snp.leading).offset(-16)
            make.bottom.equalToSuperview()
        }

        collaborativeSwitch.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
        }

        createButton.snp.makeConstraints { make in
            make.top.equalTo(formStackView.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-40)
            make.height.equalTo(52)
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func setupNavigationBar() {
        navigationItem.title = ""
        navigationItem.largeTitleDisplayMode = .never

        let cancelButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: nil,
            action: nil
        )
        navigationItem.leftBarButtonItem = cancelButton

        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.reactor?.action.onNext(.dismiss)
            })
            .disposed(by: disposeBag)
    }

    private func setupTextViewDelegate() {
        descriptionTextView.delegate = self
    }

    private func setupKeyboardHandling() {
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] notification in
                self?.handleKeyboardShow(notification)
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { [weak self] notification in
                self?.handleKeyboardHide(notification)
            })
            .disposed(by: disposeBag)
    }

    private func handleKeyboardShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardHeight = keyboardFrame.height
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    private func handleKeyboardHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

    // MARK: - Binding

    public func bind(reactor: CreatePlaylistReactor) {
        // Input
        nameTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .map { CreatePlaylistReactor.Action.updateName($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        descriptionTextView.rx.text.orEmpty
            .distinctUntilChanged()
            .map { CreatePlaylistReactor.Action.updateDescription($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        publicSwitch.rx.isOn
            .distinctUntilChanged()
            .map { CreatePlaylistReactor.Action.togglePublic($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        collaborativeSwitch.rx.isOn
            .distinctUntilChanged()
            .map { CreatePlaylistReactor.Action.toggleCollaborative($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        createButton.rx.tap
            .map { CreatePlaylistReactor.Action.createPlaylist }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Output
        reactor.state.map { $0.canCreate }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: createButton.rx.isEnabled)
            .disposed(by: disposeBag)

        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                    self?.createButton.setTitle("", for: .normal)
                } else {
                    self?.loadingIndicator.stopAnimating()
                    self?.createButton.setTitle("플레이리스트 생성", for: .normal)
                }
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.errorMessage }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] errorMessage in
                self?.showErrorAlert(message: errorMessage)
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.shouldDismiss }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.didFinish()
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.createdPlaylist }
            .distinctUntilChanged { $0?.id == $1?.id }
            .observe(on: MainScheduler.asyncInstance)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] playlist in
                self?.showSuccessAlert(playlistName: playlist.name)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Private Methods

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    private func showSuccessAlert(playlistName: String) {
        let alert = UIAlertController(
            title: "생성 완료",
            message: "'\(playlistName)' 플레이리스트가 성공적으로 생성되었습니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.coordinator?.didFinish()
        })
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate

extension CreatePlaylistViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholderLabel.isHidden = !textView.text.isEmpty
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        let newLength = currentText.count + text.count - range.length
        return newLength <= 300
    }
}