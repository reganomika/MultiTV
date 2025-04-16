import UIKit
import Utilities

final class RemoteTVController: BaseController {
    
    // MARK: - UI Components
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "phone"))
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var navigationTitleLabel = UILabel().apply {
        $0.text = "Not connected".localized
        $0.font = .font(weight: .bold, size: 25)
    }
    
    private lazy var topButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "connect"), for: .normal)
        button.addTarget(self, action: #selector(handleConnectAction), for: .touchUpInside)
        button.applyDropShadow(
            color: .init(hex: "0055F1"),
            opacity: 0.49,
            offset: CGSize(width: 0, height: 4),
            radius: 21
        )
        return button
    }()
    
    private lazy var topButtonsView: UIView = UIView()
    private lazy var bottomButtonsView: UIView = UIView()
    private lazy var centerButtonsView: UIView = UIView()
    
    private lazy var powerButton = createTransparentButton(action: #selector(handlePowerButtonTap))
    private lazy var homeButton = createTransparentButton(action: #selector(handleHomeButtonTap))
    private lazy var menuButton = createTransparentButton(action: #selector(handleMenuButtonTap))
    
    private lazy var centerButton = createTransparentButton(action: #selector(handleCenterButtonTap))
    private lazy var upButton = createTransparentButton(action: #selector(handleUpButtonTap))
    private lazy var downButton = createTransparentButton(action: #selector(handleDownButtonTap))
    private lazy var leftButton = createTransparentButton(action: #selector(handleLeftButtonTap))
    private lazy var rightButton = createTransparentButton(action: #selector(handleRightButtonTap))
    
    private lazy var volPlusButton = createTransparentButton(action: #selector(handleVolPlusButtonTap))
    private lazy var volMinusButton = createTransparentButton(action: #selector(handleVolMinusButtonTap))
    private lazy var backButton = createTransparentButton(action: #selector(handleBackButtonTap))
    private lazy var muteButton = createTransparentButton(action: #selector(handleMuteButtonTap))
    private lazy var channelUpButton = createTransparentButton(action: #selector(handleChannelUpButtonTap))
    private lazy var channelDownButton = createTransparentButton(action: #selector(handleChannelDownButtonTap))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        configureViewHierarchy()
        setupObservers()
    }
    
    private func configureNavigation() {
        configurNavigation(leftView: navigationTitleLabel, rightView: topButton)
    }
    
    private func configureViewHierarchy() {
        view.addSubviews(imageView)
        
        imageView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(98)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(94)
            make.width.equalTo(imageView.snp.height).multipliedBy(295.0/567.0)
        }
        
        imageView.addSubviews(topButtonsView, bottomButtonsView, centerButtonsView)
        
        topButtonsView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(imageView.snp.height).multipliedBy(0.19)
        }
        
        bottomButtonsView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(imageView.snp.height).multipliedBy(0.36)
        }
        
        centerButtonsView.snp.makeConstraints { make in
            make.top.equalTo(topButtonsView.snp.bottom)
            make.bottom.equalTo(bottomButtonsView.snp.top)
            make.left.right.equalToSuperview()
        }
        
        centerButtonsView.addSubviews(centerButton, upButton, downButton, leftButton, rightButton)
        
        let centerButtonMultiplier = 1.0/3.0
        centerButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalToSuperview().multipliedBy(centerButtonMultiplier)
        }
        
        upButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(centerButton.snp.top)
            $0.width.height.equalToSuperview().multipliedBy(centerButtonMultiplier)
        }
        
        downButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(centerButton.snp.bottom)
            $0.width.height.equalToSuperview().multipliedBy(centerButtonMultiplier)
        }
        
        leftButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(centerButton.snp.leading)
            $0.width.height.equalToSuperview().multipliedBy(centerButtonMultiplier)
        }
        
        rightButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(centerButton.snp.trailing)
            $0.width.height.equalToSuperview().multipliedBy(centerButtonMultiplier)
        }
        
        bottomButtonsView.addSubviews(volPlusButton, volMinusButton, backButton, muteButton, channelUpButton, channelDownButton)
        
        volPlusButton.snp.makeConstraints {
            $0.left.top.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(1.0/3.0)
            $0.height.equalToSuperview().multipliedBy(1.0/2.0)
        }
        
        volMinusButton.snp.makeConstraints {
            $0.left.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(1.0/3.0)
            $0.height.equalToSuperview().multipliedBy(1.0/2.0)
        }
        
        backButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(1.0/3.0)
            $0.height.equalToSuperview().multipliedBy(1.0/2.0)
        }
        
        muteButton.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(1.0/3.0)
            $0.height.equalToSuperview().multipliedBy(1.0/2.0)
        }
        
        channelUpButton.snp.makeConstraints {
            $0.right.top.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(1.0/3.0)
            $0.height.equalToSuperview().multipliedBy(1.0/2.0)
        }
        
        channelDownButton.snp.makeConstraints {
            $0.right.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(1.0/3.0)
            $0.height.equalToSuperview().multipliedBy(1.0/2.0)
        }
        
        topButtonsView.addSubviews(powerButton, homeButton, menuButton)
        
        powerButton.snp.makeConstraints {
            $0.left.top.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(1.0/3.0)
            $0.height.equalToSuperview()
        }
        
        homeButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(1.0/3.0)
            $0.height.equalToSuperview()
        }
        
        menuButton.snp.makeConstraints {
            $0.right.top.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(1.0/3.0)
            $0.height.equalToSuperview()
        }
    }
    
    private func setupObservers() {
//        SamsungTVConnectionService.shared.connectionStatusPublisher
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] isConnected in
//                self?.updateUI(forConnectionStatus: isConnected)
//            }
//            .store(in: &cancellables)
    }
    
    private func createTransparentButton(action: Selector) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    @objc private func handleConnectAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
//        present(vc: DevicesController())
    }
    
    @objc private func handleHomeButtonTap() {  }
    @objc private func handlePowerButtonTap() {  }
    @objc private func handleMenuButtonTap() {  }
    
    @objc private func handleCenterButtonTap() {  }
    @objc private func handleUpButtonTap() {  }
    @objc private func handleDownButtonTap() {  }
    @objc private func handleLeftButtonTap() {  }
    @objc private func handleRightButtonTap() {  }
    
    @objc private func handleVolPlusButtonTap() {  }
    @objc private func handleVolMinusButtonTap() {  }
    @objc private func handleBackButtonTap() {  }
    @objc private func handleMuteButtonTap() {  }
    @objc private func handleChannelUpButtonTap() {  }
    @objc private func handleChannelDownButtonTap() {  }
}
