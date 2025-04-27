import UIKit
import SnapKit
import UniversalTVRemote
import Utilities

final class DeviceCell: UITableViewCell {
    
    static let reuseID = "DeviceCell"
    
    private lazy var customBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .init(hex: "4E4F5C")
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let leftImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "device"))
        return imageView
    }()
    
    private let rightImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "chevron"))
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .bold, size: 18)
        label.textColor = .white
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .semiBold, size: 16)
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 6
        return stackView
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
        customBackgroundView.addSubview(rightImageView)
        customBackgroundView.addSubview(stackView)
        
        leftImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(19)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(35)
        }
        
        rightImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(23)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(24)
        }
        
        customBackgroundView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(12)
        }
        
        stackView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(67)
            make.right.equalToSuperview().inset(89)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(tv: Device) {
        
        titleLabel.text = tv.name
        
        let isConnected = Storage.shared.restoreConnectedDevice()?.address == tv.address
        
        subtitleLabel.text = isConnected ? "Synced".localized : "Not synced".localized
        subtitleLabel.textColor = isConnected ? UIColor.init(hex: "00FF51") : .white.withAlphaComponent(0.65)
    }
}
