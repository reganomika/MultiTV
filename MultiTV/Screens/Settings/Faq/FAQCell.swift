import UIKit
import SnapKit
import Utilities

final class FAQCell: UITableViewCell {
    
    static let identifier = "FAQCell"
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.22)
        return view
    }()
    
    private let rightImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .font(weight: .semiBold, size: 18)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
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
                
        contentView.addSubview(rightImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(separatorView)
        
        rightImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(35)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(24)
            make.right.equalToSuperview().inset(70)
            make.top.equalToSuperview().inset(21)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(24)
            make.right.equalToSuperview().inset(70)
            make.top.equalTo(titleLabel.snp.bottom).inset(-10)
            make.bottom.equalToSuperview().inset(21)
        }
        
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.right.left.equalToSuperview()
        }
    }
    
    func configure(model: FAQModel, isExpanded: Bool, isSeparatorHidden: Bool) {

        titleLabel.text = model.title
        
        subtitleLabel.isHidden = !isExpanded
        
        
        let subtitleString: String
        
        if isExpanded {
            subtitleString = model.subtitle
        } else {
            subtitleString = ""
        }
        
        subtitleLabel.attributedText = subtitleString.localized.attributedString(
            font: .font(weight: .medium, size: 16),
            aligment: .left,
            color: .white,
            lineSpacing: 2,
            maxHeight: 40
        )
        
        rightImageView.image = isExpanded ? UIImage(named: "arrowUp") : UIImage(named: "arrowBottom")
        
        separatorView.isHidden = isSeparatorHidden
    }
}
