import Utilities
import UIKit
import SnapKit
import TVRemoteControl

final class BaseCell: UITableViewCell {
    
    static let reuseID = "BaseCell"
    
    private lazy var customBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .init(hex: "353644")
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let leftImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .semiBold, size: 18)
        label.textColor = .white
        return label
    }()
    
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
        
        contentView.addSubview(customBackgroundView)
        
        customBackgroundView.addSubview(leftImageView)
        customBackgroundView.addSubview(titleLabel)
        
        leftImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(35)
        }
        
        customBackgroundView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(14)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(62)
            make.right.equalToSuperview().inset(22)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(type: SettingsOption) {
        titleLabel.text = type.displayTitle
        leftImageView.image = type.iconAsset
    }
    
//    func configure(app: SamsungTVApp) {
//        titleLabel.text = app.name
//        leftImageView.image = app.iconImage
//        
//        leftImageView.snp.updateConstraints { make in
//            make.left.equalToSuperview().inset(20)
//            make.height.width.equalTo(50)
//        }
//        
//        titleLabel.snp.updateConstraints { make in
//            make.left.equalToSuperview().inset(96)
//        }
//    }
}
