import UIKit
import SafariServices
import SnapKit
import CustomBlurEffectView
import ShadowImageButton
import Utilities

// MARK: - Constants

private enum Constants {
    static let contentViewHeight: CGFloat = 390
    static let contentViewWidth: CGFloat = 343
    static let buttonHeight: CGFloat = 56
    static let buttonCornerRadius: CGFloat = 28
    static let shadowRadius: CGFloat = 14.7
    static let shadowOffset = CGSize(width: 0, height: 4)
    static let shadowOpacity: Float = 0.6
    static let contentInsets = UIEdgeInsets(top: 0, left: 28, bottom: 61, right: 28)
    static let textInsets: CGFloat = 34.0
}

// MARK: - ReviewController

final class ReviewController: UIViewController {
    
    // MARK: - UI Components
    
    private lazy var blurView = CustomBlurEffectView().apply {
        $0.blurRadius = 20
        $0.colorTint = UIColor(hex: "171313")
        $0.colorTintAlpha = 0.3
    }
    
    private lazy var contentView = UIView().apply {
        $0.backgroundColor = UIColor(hex: "4E4F5C")
        $0.layer.cornerRadius = 20
    }
    
    private lazy var appImageView = UIImageView().apply {
        $0.image = UIImage(named: "review")
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }
    
    private lazy var titleLabel = UILabel().apply {
        $0.numberOfLines = 0
        $0.attributedText = "Would you recommend our app to others?".localized.attributedString(
            font: .font(weight: .bold, size: 22),
            aligment: .center,
            color: UIColor.white,
            lineSpacing: 5,
            maxHeight: 50
        )
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    private lazy var subtitleLabel = UILabel().apply {
        $0.numberOfLines = 0
        $0.attributedText = "We’d be thrilled to hear your thoughts on your experience with the app".localized.attributedString(
            font: .font(weight: .semiBold, size: 16),
            aligment: .center,
            color: UIColor.white.withAlphaComponent(0.65),
            lineSpacing: 5,
            maxHeight: 50
        )
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    private lazy var feedbackButton = ShadowImageButton().apply {
        $0.configure(
            buttonConfig: .init(
                title: "I like it".localized,
                font: .font(weight: .bold, size: 18),
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
        $0.backgroundColor = .init(hex: "0055F1")
        $0.action = { [weak self] in self?.handleFeedbackAction() }
    }
    
    private lazy var closeButton = UIButton().apply {
        $0.setTitle("Later".localized, for: .normal)
        $0.titleLabel?.font = .font(weight: .semiBold, size: 16)
        $0.setTitleColor(UIColor.white.withAlphaComponent(0.65), for: .normal)
        $0.addTarget(self, action: #selector(handleCloseAction), for: .touchUpInside)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewHierarchy()
        configureLayoutConstraints()
        markFeedbackAsShown()
    }
    
    // MARK: - Private Methods
    
    private func configureViewHierarchy() {
        view.addSubview(blurView)
        blurView.addSubview(contentView)
        
        contentView.addSubviews(
            appImageView,
            titleLabel,
            subtitleLabel,
            feedbackButton,
            closeButton
        )
    }
    
    private func configureLayoutConstraints() {
        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        contentView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(Constants.contentViewHeight)
            $0.width.equalTo(Constants.contentViewWidth)
        }
        
        appImageView.snp.makeConstraints {
            $0.bottom.equalTo(titleLabel.snp.top).inset(-10)
            $0.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.bottom.equalTo(subtitleLabel.snp.top).offset(-12)
            $0.leading.trailing.equalToSuperview().inset(55)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.bottom.equalTo(feedbackButton.snp.top).offset(-27)
            $0.leading.trailing.equalToSuperview().inset(Constants.textInsets)
        }
        
        feedbackButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(18)
            $0.height.equalTo(Constants.buttonHeight)
            $0.bottom.equalToSuperview().inset(56)
        }
        
        closeButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(14)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(21)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.feedbackButton.addButtonInnerShadow()
        }
    }
    
    private func markFeedbackAsShown() {
        Storage.shared.wasRevviewScreen = true
    }
    
    private func presentAppStoreReview() {
        guard let url = URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id\(Config.appId)?action=write-review") else { return }
        present(SFSafariViewController(url: url), animated: true)
    }
    
    private func generateHapticFeedback() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    // MARK: - Actions
    
    @objc private func handleCloseAction() {
        generateHapticFeedback()
        dismiss(animated: true)
    }
    
    @objc private func handleFeedbackAction() {
        generateHapticFeedback()
        presentAppStoreReview()
    }
}

extension UIView {
    public func addButtonInnerShadow() {
        layer.sublayers?.filter { $0.name == "innerShadow" }.forEach { $0.removeFromSuperlayer() }
        
        let innerShadow = CALayer()
        innerShadow.name = "innerShadow"
        innerShadow.frame = bounds
        
        let radius = layer.cornerRadius
        let shadowThickness: CGFloat = 1
        let path = UIBezierPath(roundedRect: innerShadow.bounds.insetBy(dx: -shadowThickness, dy: -shadowThickness), cornerRadius: radius)
        let cutout = UIBezierPath(roundedRect: innerShadow.bounds.insetBy(dx: shadowThickness, dy: shadowThickness), cornerRadius: radius).reversing()
        
        path.append(cutout)
        innerShadow.shadowPath = path.cgPath
        innerShadow.masksToBounds = true
        
        innerShadow.shadowColor = UIColor.white.cgColor
        innerShadow.shadowOffset = CGSize(width: 0, height: 2)
        innerShadow.shadowOpacity = 0.25
        innerShadow.shadowRadius = shadowThickness
        innerShadow.cornerRadius = radius
        layer.addSublayer(innerShadow)
    }
}
