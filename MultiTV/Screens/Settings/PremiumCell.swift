import UIKit
import SnapKit
import ShadowImageButton
import Utilities

class PremiumCell: UITableViewCell {
    static let reuseID = "PremiumCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.applyDropShadow(
            color: UIColor(hex: "0055F1"),
            opacity: 0.61,
            offset: CGSize(width: 0, height: 4),
            radius: 20
        )
        view.backgroundColor = .init(hex: "0055F1")
        view.layer.cornerRadius = 22
        return view
    }()
    
    private let rightImageView: UIImageView = {
        UIImageView(image: UIImage(named: "rightPremiumCell"))
    }()
    
    private let promotionTitle: UILabel = {
        let label = UILabel()
        
        label.attributedText = "Unlock full control 🔓".localized.attributedString(
            font: .font(weight: .bold, size: 24),
            aligment: .left,
            color:. white,
            lineSpacing: 5,
            maxHeight: 50
        )
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let promotionSubtitle: UILabel = {
        let label = UILabel()
        
        label.attributedText = "Get unlimited access to Universal Remote TV".localized.attributedString(
            font: .font(weight: .semiBold, size: 16),
            aligment: .left,
            color: UIColor.white.withAlphaComponent(0.64),
            lineSpacing: 5,
            maxHeight: 30
        )
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Upgrade 🚀".localized, for: .normal)
        button.titleLabel?.font = .font(weight: .bold, size: 16)
        button.setTitleColor(UIColor(hex: "0B0C1E"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 21
        button.applyDropShadow(
            color: .white,
            opacity: 0.6,
            offset: CGSize(width: 0, height: 4),
            radius: 21
        )
        button.isUserInteractionEnabled = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubviews(promotionTitle, promotionSubtitle, actionButton, rightImageView)
        
        containerView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.verticalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(192)
        }
        
        promotionTitle.snp.makeConstraints {
            $0.leading.equalTo(actionButton)
            $0.width.equalTo(170)
            $0.top.equalToSuperview().inset(18)
        }
        
        promotionSubtitle.snp.makeConstraints {
            $0.leading.equalTo(actionButton)
            $0.width.equalTo(170)
            $0.top.equalTo(promotionTitle.snp.bottom).offset(10)
        }
        
        actionButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(18)
            $0.size.equalTo(CGSize(width: 110, height: 42))
        }
        
        rightImageView.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.containerView.addButtonInnerShadow()
        }
    }
}

// MARK: - Extensions

extension UIView {
    func applyDropShadow(color: UIColor, opacity: Float, offset: CGSize, radius: CGFloat) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
}
