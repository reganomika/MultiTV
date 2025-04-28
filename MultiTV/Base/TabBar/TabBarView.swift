import UIKit
import SnapKit
import Utilities

protocol TabBarViewDelegate: AnyObject {
    func tabBarView(_ tabBarView: TabBarView, didSelectItemAt index: Int)
}

enum TabBarViewItemType {
    case normal(UIImage?)
}

final class TabBarView: UIView {
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .init(hex: "353644")
        view.layer.cornerRadius = 20
        return view
    }()

    weak var delegate: TabBarViewDelegate?
    private var buttons: [UIStackView] = []
    private let items: [TabBarViewItemType] = [
        .normal(UIImage(named: "appsTab")),
        .normal(UIImage(named: "remoteTab")),
        .normal(UIImage(named: "settingsTab"))
    ]

    private lazy var tabBarStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        return stackView
    }()

    init() {
        super.init(frame: .zero)
        setupTabBarButtons()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTabBarButtons() {
        for (index, item) in items.enumerated() {
            
            switch item {
            case .normal(let image):
                
                let view = UIView()
                view.backgroundColor = .clear
                view.layer.cornerRadius = 36
                
                view.snp.makeConstraints { make in
                    make.height.width.equalTo(75)
                }
                
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFit
                
                view.addSubview(imageView)
                
                imageView.snp.makeConstraints { make in
                    make.center.equalToSuperview()
                }
                
                let stackView = UIStackView(arrangedSubviews: [view])
                stackView.axis = .vertical
                stackView.alignment = .center
                stackView.spacing = 4
                stackView.tag = index
                
                stackView.add(target: self, action: #selector(tabButtonTapped(_:)))
                
                stackView.snp.makeConstraints { make in
                    make.height.width.equalTo(75)
                }
                
                tabBarStackView.addArrangedSubview(stackView)
                
                buttons.append(stackView)
            }
        }

        updateSelectedButton(at: 1)
    }

    private func setupLayout() {
        addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(25)
            make.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(17)
        }
        
        contentView.addSubview(tabBarStackView)
        
        tabBarStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(40)
            make.height.equalTo(75)
            make.centerY.equalToSuperview()
        }
    }

    @objc private func tabButtonTapped(_ sender: UITapGestureRecognizer) {
        guard let selectedIndex = sender.view?.tag else { return }
        updateSelectedButton(at: selectedIndex)
        delegate?.tabBarView(self, didSelectItemAt: selectedIndex)
    }

    private func updateSelectedButton(at index: Int) {
        for (buttonIndex, item) in items.enumerated() {
            guard case .normal(let image) = item else { continue }

            let buttonStackView = buttons[buttonIndex]
            
            let view = buttonStackView.arrangedSubviews[0]
            let imageView = view.subviews.first as? UIImageView
            
            imageView?.image = image?.withTintColor(buttonIndex == index ? UIColor.white : UIColor.white.withAlphaComponent(0.38))
            view.transform = buttonIndex == index ? CGAffineTransform(translationX: 0, y: -20) : .identity
            
            view.backgroundColor = buttonIndex == index ? UIColor.init(hex: "0055F1") : .clear
            
            if buttonIndex == index {
                view.layer.shadowColor = UIColor.init(hex: "0055F1").cgColor
                view.layer.shadowOpacity = 0.49
                view.layer.shadowOffset = .init(width: 0, height: 6)
                view.layer.shadowRadius = 17
                view.layer.masksToBounds = false
            } else {
                view.layer.shadowColor = nil
                view.layer.shadowOpacity = 0
                view.layer.shadowOffset = .zero
                view.layer.shadowRadius = 0
                view.layer.masksToBounds = true
            }
        }
    }
}
