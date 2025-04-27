import UIKit
import SnapKit
import Utilities

class BaseSwitchView: UIView {
    
    private lazy var selectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .init(hex: "0B0C1E")
        view.layer.cornerRadius = 23.5
        return view
    }()
    
    private lazy var leftButton: UIButton = {
        let button = UIButton()
        button.setTitle("year".localized.capitalized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .font(weight: .bold, size: 18)
        button.addTarget(self, action: #selector(leftTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var rightButton: UIButton = {
        let button = UIButton()
        button.setTitle("week".localized.capitalized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .font(weight: .bold, size: 18)
        button.addTarget(self, action: #selector(rightTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .init(hex: "4E4F5C")
        view.layer.cornerRadius = 26.5
        return view
    }()
    
    var isLeftSelected = true
    
    var onLeftSelected: (() -> Void)?
    var onRightSelected: (() -> Void)?
    
    private var selectionViewLeftConstraint: Constraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = true
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(containerView)
        containerView.addSubview(selectionView)
        containerView.addSubview(leftButton)
        containerView.addSubview(rightButton)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        leftButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        rightButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        selectionView.snp.makeConstraints { make in
            selectionViewLeftConstraint = make.left.equalToSuperview().inset(3).constraint
            make.top.bottom.equalToSuperview().inset(3)
            make.width.equalToSuperview().multipliedBy(0.5)
        }
    }
    
    private func animateSelection(toLeft: Bool) {
        let offset = toLeft ? 3 : (self.containerView.frame.width / 2) - 3
        
        selectionViewLeftConstraint?.update(offset: offset)
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    @objc private func leftTapped() {
        if !isLeftSelected {
            isLeftSelected = true
            animateSelection(toLeft: true)
            onLeftSelected?()
        }
    }
    
    @objc private func rightTapped() {
        if isLeftSelected {
            isLeftSelected = false
            animateSelection(toLeft: false)
            onRightSelected?()
        }
    }
}
