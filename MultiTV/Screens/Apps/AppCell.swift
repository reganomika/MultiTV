import UIKit
import SnapKit
import UniversalTVRemote
import SDWebImage

class AppCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 13
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        clipsToBounds = true
        layer.cornerRadius = 10
        contentView.addSubview(imageView)
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    func configure(lg: LGRemoteControlResponseApplication) {
        if let id = lg.id {
            imageView.image = LGApp(rawValue: id)?.image
        }
    }
    
    func configure(samsung: SamsungTVApp) {
        imageView.image = samsung.iconImage
    }
    
    func configure(amazon: FireStickApp) {
        imageView.sd_setImage(with: URL(string: amazon.iconArtSmallUri))
    }
}
