import UIKit
import PremiumManager
import StoreKit
import SafariServices
import SnapKit
import RxSwift
import ShadowImageButton
import Utilities
import ApphudSDK

class PaywallOldController: OnboardingController {
    
    private let fourthButton = UIButton()
    
    public var customTitle: String = "" {
        didSet {
            updateTitle()
        }
    }
    
    public var customSubtitle: String = "" {
        didSet {
            subtitleLabel.attributedText = customSubtitle.attributedString(
                font: .font(weight: .semiBold, size: 16),
                aligment: .center,
                color: .white.withAlphaComponent(0.74),
                lineSpacing: 5,
                maxHeight: 50
            )
        }
    }
    
    let highlightedText: String = "Premium".localized
    
    private let isFromOnboarding: Bool
    
    private let premiumManager = PremiumManager.shared
    
    private lazy var product: ApphudProduct? = {
        premiumManager.products.value.first
    }()
    
    init(isFromOnboarding: Bool) {
        self.isFromOnboarding = isFromOnboarding
        super.init(
            model: OnboardingModel(image: UIImage(), title: "", higlitedText: "", subtitle: "", rating: false),
            coordinator: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        customTitle = "Unlock Premium Features!".localized
        
        if let price = product?.price, let duration = product?.duration?.rawValue.localized {
            customSubtitle = String(format: "Upgrade to Premium and enjoy the best remote experience for".localized, "\(price)/\(duration)")
        }
       
        imageView.image = UIImage(named: "paywall_0")
    }
    
    override func setupButtons() {
        
        bottomStackView.axis = .horizontal
        bottomStackView.distribution = .fillEqually
        bottomStackView.spacing = 16
        
        let newButton = createBottomButton(title: "Not now".localized)
        newButton.addTarget(self, action: #selector(closePaywall), for: .touchUpInside)
        
        let privacyButton = createBottomButton(title: "Privacy".localized)
        let restoreButton = createBottomButton(title: "Restore".localized)
        let termsButton = createBottomButton(title: "Terms".localized)
        
        privacyButton.addTarget(self, action: #selector(openPrivacy), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(restore), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(openTerms), for: .touchUpInside)
        
        bottomStackView.addArrangedSubview(privacyButton)
        bottomStackView.addArrangedSubview(restoreButton)
        bottomStackView.addArrangedSubview(termsButton)
        bottomStackView.addArrangedSubview(newButton)
        
        view.addSubview(bottomStackView)
        
        bottomStackView.snp.remakeConstraints { make in
            make.top.equalTo(nextButton.snp.bottom).offset(21)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(18)
        }
    }
    
    private func updateTitle() {
        let attributedString = NSMutableAttributedString(attributedString: customTitle.attributedString(
            font: .font(weight: .bold, size: 28),
            aligment: .center,
            color: .white,
            lineSpacing: 5,
            maxHeight: 50
        ))
        
        if !highlightedText.isEmpty {
            let range = (customTitle as NSString).range(of: highlightedText)
            attributedString.addAttribute(.foregroundColor, value: UIColor.init(hex: "00BFFF"), range: range)
        }
        
        titleLabel.attributedText = attributedString
    }
    
    @objc private func closePaywall() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        closeAction()
    }
    
    override func closeAction() {
        if isFromOnboarding {
            replaceRootViewController(with: TabBarController())
        } else {
            dismiss()
        }
    }
    
    override func nexAction() {
        premiumManager.purchase(product: product)
    }
}
