import UIKit
import PremiumManager
import StoreKit
import SafariServices
import SnapKit
import RxSwift
import ShadowImageButton
import Utilities

private enum Constants {
    static let buttonHeight: CGFloat = 64
    static let buttonCornerRadius: CGFloat = 32
    static let shadowRadius: CGFloat = 14.7
    static let shadowOffset = CGSize(width: 0, height: 4)
    static let shadowOpacity: Float = 0.6
}

class OnboardingController: UIViewController {
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let bottomStackView = UIStackView()
    
    let disposeBag = DisposeBag()
    
    lazy var nextButton: ShadowImageButton = {
        let button = ShadowImageButton()
        button.configure(
            buttonConfig: .init(
                title: "Continue".localized,
                font: .font(
                    weight: .bold,
                    size: 18
                ),
                textColor: .white,
                image: nil
            ),
            backgroundImageConfig: .init(
                image: nil,
                cornerRadius: Constants.buttonCornerRadius,
                shadowConfig: .init(
                    color: UIColor(hex: "117FF5"),
                    opacity: Constants.shadowOpacity,
                    offset: Constants.shadowOffset,
                    radius: Constants.shadowRadius
                )
            )
        )
        button.backgroundColor = .init(hex: "0055F1")
        button.add(target: self, action: #selector(nextButtonTapped))
        return button
    }()
    
    weak var coordinator: OnboardingCoordinator?
    let model: OnboardingModel
    
    init(model: OnboardingModel, coordinator: OnboardingCoordinator?) {
        self.model = model
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupButtons()
        
        PremiumManager.shared.isPremium
            .observe(on: MainScheduler.instance)
            .filter { $0 }
            .subscribe(onNext: { [weak self] isPremium in
                if isPremium {
                    self?.close()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setupViews() {
        view.backgroundColor = .init(hex: "171313")
        
        imageView.image = model.image
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
        
        titleLabel.numberOfLines = 0
        
        let attributedString = NSMutableAttributedString(attributedString: model.title.attributedString(
            font: .font(weight: .bold, size: 28),
            aligment: .center,
            color: .white,
            lineSpacing: 5,
            maxHeight: 50
        ))
        let range = (model.title as NSString).range(of: model.higlitedText)
        attributedString.addAttribute(.foregroundColor, value: UIColor.init(hex: "00BFFF"), range: range)
        
        titleLabel.attributedText = attributedString

        view.addSubview(titleLabel)
        
        subtitleLabel.numberOfLines = 0
        
        subtitleLabel.attributedText = model.subtitle.attributedString(
            font: .font(weight: .semiBold, size: 16),
            aligment: .center,
            color: .white.withAlphaComponent(0.74),
            lineSpacing: 5,
            maxHeight: 50
        )
        view.addSubview(subtitleLabel)
        
        view.addSubview(nextButton)
    }
    
    func setupButtons() {
        bottomStackView.axis = .horizontal
        bottomStackView.distribution = .fillEqually
        bottomStackView.spacing = 16
        
        let privacyButton = createBottomButton(title: "Privacy".localized)
        let restoreButton = createBottomButton(title: "Restore".localized)
        let termsButton = createBottomButton(title: "Terms".localized)
        
        privacyButton.addTarget(self, action: #selector(openPrivacy), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(restore), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(openTerms), for: .touchUpInside)
        
        bottomStackView.addArrangedSubview(privacyButton)
        bottomStackView.addArrangedSubview(restoreButton)
        bottomStackView.addArrangedSubview(termsButton)
        
        view.addSubview(bottomStackView)
        
        bottomStackView.snp.makeConstraints { make in
            make.top.equalTo(nextButton.snp.bottom).offset(21)
            make.leading.trailing.equalToSuperview().inset(26)
            make.height.equalTo(18)
        }
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(subtitleLabel.snp.top).inset(-15)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(nextButton.snp.top).inset(-36)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-69)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(Constants.buttonHeight)
        }
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.nextButton.addButtonInnerShadow()
        }
    }
    
    func createBottomButton(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.65), for: .normal)
        button.titleLabel?.font = .font(weight: .medium, size: Locale().isEnglish ? 13 : 10)
        return button
    }
    
    @objc private func nextButtonTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        nexAction()
    }
    
    func nexAction() {
        if model.rating {
            SKStoreReviewController.requestReview()
        }
        coordinator?.goToNextScreen()
    }
    
    @objc func openPrivacy() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if let url = URL(string: Config.privacy) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    }
    
    @objc func openTerms() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if let url = URL(string: Config.terms) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    }
    
    @objc func restore() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        PremiumManager.shared.restorePurchases()
    }
    
    @objc private func close() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        replaceRootViewController(with: TabBarController())
    }
}
