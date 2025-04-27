import UIKit
import SnapKit
import Utilities

final class PaywallOptionView: UIView {
    
    var isSelectedOption: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    lazy var imageView: UIImageView = {
        UIImageView(image: UIImage(named: "paywall_unselected"))
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .font(weight: .bold, size: 16)
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .init(hex: "AFB0AF")
        label.font = .font(weight: .medium, size: 16)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var rightTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .init(hex: "AFB0AF")
        label.font = .font(weight: .semiBold, size: 16)
        label.textAlignment = .right
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        return stackView
    }()
    
    lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, stackView, rightTitleLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 16
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, subtitle: String?, rightTitle: String, isSelected: Bool) {
        titleLabel.text = title
        rightTitleLabel.text = rightTitle
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
        isSelectedOption = isSelected
    }
    
    func setupUI() {
        addSubview(horizontalStackView)
        
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
    }
    
    func setupConstraints() {
        horizontalStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(24)
        }
    }
    
    func updateAppearance() {
        
        imageView.image = UIImage(named: isSelectedOption ? "paywall_selected" : "paywall_unselected" )

        if isSelectedOption {
            backgroundColor = UIColor.white.withAlphaComponent(0.14)
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
            applyGradientBorder(
                colors: [UIColor.init(hex: "01D4C9"), UIColor.init(hex: "00FFA1")],
                lineWidth: 6, cornerRadius: 16
            )
        } else {
            backgroundColor = .clear
            layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
            layer.borderWidth = 1
            layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        }
    }
}
