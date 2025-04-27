import UIKit
import SnapKit
import ShadowImageButton
import Utilities
import Lottie

final class DeviceSearchCell: UITableViewCell {
    
    static let reuseID = "DeviceSearchCell"
    
    private let centerImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "notFound"))
        return imageView
    }()

    private lazy var animationView: LottieAnimationView = {
        let path = Bundle.main.path(
            forResource: "search",
            ofType: "json"
        ) ?? ""
        let animationView = LottieAnimationView(filePath: path)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.0
        animationView.play()
        return animationView
    }()
    
    private lazy var connectionTitleLabel = UILabel().apply {
        $0.font = .font(weight: .bold, size: 25)
        $0.text = "Searching for devices...".localized
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private lazy var connectionSubtitleLabel = UILabel().apply {
        $0.font = .font(weight: .semiBold, size: 18)
        $0.textColor = UIColor.white.withAlphaComponent(0.65)
        $0.text = "For best performance, your phone and TV should share the same Wi-Fi".localized
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private lazy var connectionStackView = UIStackView(arrangedSubviews: [
        connectionTitleLabel,
        connectionSubtitleLabel
    ]).apply {
        $0.axis = .vertical
        $0.spacing = 15
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(animationView)
        contentView.addSubview(connectionStackView)
        contentView.addSubview(centerImageView)
       
        animationView.snp.makeConstraints { make in
            make.height.width.equalTo(UIScreen.isLittleDevice ? 200 : 276)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(connectionStackView.snp.top).inset(-40)
        }
        
        centerImageView.snp.makeConstraints { make in
            make.height.width.equalTo(UIScreen.isLittleDevice ? 200 : 276)
            make.center.equalTo(animationView)
        }
        
        connectionStackView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(20)
            make.left.right.equalToSuperview().inset(50)
            make.height.equalTo(81)
        }
    }
    
    func configure(isNotFound: Bool) {
        connectionTitleLabel.text = isNotFound ? "Couldn’t find a Smart TV".localized : "Searching for devices...".localized
        animationView.isHidden = isNotFound
        centerImageView.isHidden = !isNotFound
    }
}

