import UIKit
import SnapKit
import TVRemoteControl

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
        backgroundColor = .lightGray
        clipsToBounds = true
        layer.cornerRadius = 10
        contentView.addSubview(imageView)
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
//    func configure(with app: WebOSResponseApplication) {
//        
//        if let id = app.id {
//            imageView.image = App(rawValue: id)?.image
//        }
//    }
    
    func configure(app: SamsungTVApp) {
        imageView.image = app.iconImage
    }
}
