import UIKit
import SnapKit
import Utilities
import ShadowImageButton

private enum Constants {
    static let buttonCornerRadius: CGFloat = 31
    static let shadowRadius: CGFloat = 14.7
    static let shadowOffset = CGSize(width: 0, height: 4)
    static let shadowOpacity: Float = 0.6
}

final class InfoActionView: UIView {
    
    // MARK: - UI Components
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.setCustomSpacing(33, after: imageView)
        stack.setCustomSpacing(13, after: titleLabel)
        stack.alignment = .center
        return stack
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "tv"))
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .vertical)
        return imageView
    }()
    
    private let smallImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .bold, size: 25)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .semiBold, size: 18)
        label.textColor = .white.withAlphaComponent(0.65)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Properties
    
    var onActionButtonTap: (() -> Void)?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        
        addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.height.equalTo(137)
        }
        
        subtitleLabel.snp.makeConstraints { make in
//            make.height.equalTo(22)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
//            make.height.equalTo(30)
            make.centerX.equalToSuperview()
        }
        
        addSubviews(smallImageView, activityIndicator)
        
        smallImageView.snp.makeConstraints { make in
            make.center.equalTo(imageView)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(imageView)
        }
    }
    
    // MARK: - Public Methods
    
    func configure(
        customBigImage: UIImage? = nil,
        image: UIImage?,
        title: String?,
        subtitle: String?
    ) {
        imageView.image = customBigImage ?? imageView.image
        activityIndicator.isHidden = image != nil || customBigImage != nil
        smallImageView.isHidden = image == nil
        smallImageView.image = image
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
