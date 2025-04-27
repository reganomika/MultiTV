import UIKit
import Utilities
import UniversalTVRemote
import Combine

final class RemoteTVController: BaseController {
    
    private let samsungManager = SamsungTVConnectionService.shared
    private let amazonManager = FireStickControl.shared
    private let lgManager = LGTVManager.shared
    
    private var cancellables = Set<AnyCancellable>()
    
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
        samsungManager.connectionStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.updateUI(isConnected: isConnected)
            }
            .store(in: &cancellables)
        
        amazonManager.$isConnected.sink { [weak self] isConnected in
            guard let self, isConnected else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.updateUI(isConnected: isConnected)
            }
        }.store(in: &cancellables)
        
        lgManager.$isConnected.sink { [weak self] isConnected in
            guard let self, isConnected else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.updateUI(isConnected: isConnected)
            }
        }.store(in: &cancellables)
    }
    
    func updateUI(isConnected: Bool) {
        
        guard let device = Storage.shared.restoreConnectedDevice() else {
            return
        }
        
        navigationTitleLabel.text = device.name
        
        switch device.type {
        case .fireStick:
            imageView.image = UIImage(named: "fireTv")
        case .samsungTV:
            imageView.image = UIImage(named: "samsungTv")
        case .rokutv:
            imageView.image = UIImage(named: "rokuTv")
        case .lg:
            imageView.image = UIImage(named: "lgTv")
        }
    }
    
    deinit {
        cancellables.forEach({ $0.cancel() })
    }
    
    private func createTransparentButton(action: Selector) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    @objc private func handleConnectAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        presentCrossDissolve(vc: DevicesController())
    }
    
    @objc private func handleHomeButtonTap() {
        guard let device = Storage.shared.restoreConnectedDevice() else {
            presentCrossDissolve(vc: DevicesController())
            return
        }
        
        switch device.type {
        case .fireStick:
            amazonManager.sendCommand(
                ip: device.address,
                token: device.token,
                action: "home"
            )
        case .samsungTV:
            samsungManager.sendCommand(.home)
        case .rokutv:
            break
        case .lg:
            lgManager.sendKeyCommand(.home)
        }
    }
    @objc private func handlePowerButtonTap() {
        guard let device = Storage.shared.restoreConnectedDevice() else {
            presentCrossDissolve(vc: DevicesController())
            return
        }
        
        switch device.type {
        case .fireStick:
            amazonManager.sendCommand(
                ip: device.address,
                token: device.token,
                action: "sleep"
            )
        case .samsungTV:
            samsungManager.sendCommand(.powerToggle)
        case .rokutv:
            break
        case .lg:
            lgManager.sendCommand(.power)
        }
    }
    @objc private func handleMenuButtonTap() {
        guard let device = Storage.shared.restoreConnectedDevice() else {
            presentCrossDissolve(vc: DevicesController())
            return
        }
        
        switch device.type {
        case .fireStick:
            amazonManager.sendCommand(
                ip: device.address,
                token: device.token,
                action: "menu"
            )
        case .samsungTV:
            samsungManager.sendCommand(.menu)
        case .rokutv:
            break
        case .lg:
            showUnsupportedAlert()
        }
    }
    
    @objc private func handleCenterButtonTap() {
        guard let device = Storage.shared.restoreConnectedDevice() else {
            presentCrossDissolve(vc: DevicesController())
            return
        }
        
        switch device.type {
        case .fireStick:
            amazonManager.sendCommand(
                ip: device.address,
                token: device.token,
                action: "select"
            )
        case .samsungTV:
            samsungManager.sendCommand(.enter)
        case .rokutv:
            break
        case .lg:
            lgManager.sendKeyCommand(.enter)
        }
    }
    @objc private func handleUpButtonTap() {
        guard let device = Storage.shared.restoreConnectedDevice() else {
            presentCrossDissolve(vc: DevicesController())
            return
        }
        
        switch device.type {
        case .fireStick:
            amazonManager.sendCommand(
                ip: device.address,
                token: device.token,
                action: "dpad_up"
            )
        case .samsungTV:
            samsungManager.sendCommand(.up)
        case .rokutv:
            break
        case .lg:
            lgManager.sendKeyCommand(.up)
        }
    }
    @objc private func handleDownButtonTap() {
        guard let device = Storage.shared.restoreConnectedDevice() else {
            presentCrossDissolve(vc: DevicesController())
            return
        }
        
        switch device.type {
        case .fireStick:
            amazonManager.sendCommand(
                ip: device.address,
                token: device.token,
                action: "dpad_down"
            )
        case .samsungTV:
            samsungManager.sendCommand(.down)
        case .rokutv:
            break
        case .lg:
            lgManager.sendKeyCommand(.down)
        }
    }
    @objc private func handleLeftButtonTap() {
        guard let device = Storage.shared.restoreConnectedDevice() else {
            presentCrossDissolve(vc: DevicesController())
            return
        }
        
        switch device.type {
        case .fireStick:
            amazonManager.sendCommand(
                ip: device.address,
                token: device.token,
                action: "dpad_left"
            )
        case .samsungTV:
            samsungManager.sendCommand(.left)
        case .rokutv:
            break
        case .lg:
            lgManager.sendKeyCommand(.left)
        }
    }
    @objc private func handleRightButtonTap() {
        guard let device = Storage.shared.restoreConnectedDevice() else {
            presentCrossDissolve(vc: DevicesController())
            return
        }
        
        switch device.type {
        case .fireStick:
            amazonManager.sendCommand(
                ip: device.address,
                token: device.token,
                action: "dpad_right"
            )
        case .samsungTV:
            samsungManager.sendCommand(.right)
        case .rokutv:
            break
        case .lg:
            lgManager.sendKeyCommand(.right)
        }
    }
    
    @objc private func handleVolPlusButtonTap() {
        guard let device = Storage.shared.restoreConnectedDevice() else {
            presentCrossDissolve(vc: DevicesController())
            return
        }
        
        switch device.type {
        case .fireStick:
            showUnsupportedAlert()
        case .samsungTV:
            samsungManager.sendCommand(.volumeUp)
        case .rokutv:
            break
        case .lg:
            lgManager.sendKeyCommand(.volumeUp)
        }
    }
    @objc private func handleVolMinusButtonTap() {
        guard let device = Storage.shared.restoreConnectedDevice() else {
            presentCrossDissolve(vc: DevicesController())
            return
        }
        
        switch device.type {
        case .fireStick:
            showUnsupportedAlert()
        case .samsungTV:
            samsungManager.sendCommand(.volumeDown)
        case .rokutv:
            break
        case .lg:
            lgManager.sendKeyCommand(.volumeDown)
        }
    }
    @objc private func handleBackButtonTap() {
        guard let device = Storage.shared.restoreConnectedDevice() else {
            presentCrossDissolve(vc: DevicesController())
            return
        }
        
        switch device.type {
        case .fireStick:
            amazonManager.sendCommand(
                ip: device.address,
                token: device.token,
                action: "back"
            )
        case .samsungTV:
            samsungManager.sendCommand(.returnKey)
        case .rokutv:
            break
        case .lg:
            lgManager.sendKeyCommand(.back)
        }
    }
    @objc private func handleMuteButtonTap() {
        guard let device = Storage.shared.restoreConnectedDevice() else {
            presentCrossDissolve(vc: DevicesController())
            return
        }
        
        switch device.type {
        case .fireStick:
            amazonManager.sendCommand(
                ip: device.address,
                token: device.token,
                action: "mute"
            )
        case .samsungTV:
            samsungManager.sendCommand(.mute)
        case .rokutv:
            break
        case .lg:
            lgManager.sendKeyCommand(.mute)
        }
    }
    @objc private func handleChannelUpButtonTap() {
        guard let device = Storage.shared.restoreConnectedDevice() else {
            presentCrossDissolve(vc: DevicesController())
            return
        }
        
        switch device.type {
        case .fireStick:
            amazonManager.sendCommand(
                ip: device.address,
                token: device.token,
                action: "dpad_up"
            )
        case .samsungTV:
            samsungManager.sendCommand(.channelUp)
        case .rokutv:
            break
        case .lg:
            lgManager.sendKeyCommand(.channelUp)
        }
    }
    @objc private func handleChannelDownButtonTap() {
        guard let device = Storage.shared.restoreConnectedDevice() else {
            presentCrossDissolve(vc: DevicesController())
            return
        }
        
        switch device.type {
        case .fireStick:
            amazonManager.sendCommand(
                ip: device.address,
                token: device.token,
                action: "dpad_down"
            )
        case .samsungTV:
            samsungManager.sendCommand(.channelDown)
        case .rokutv:
            break
        case .lg:
            lgManager.sendKeyCommand(.channelDown)
        }
    }
    
    func showUnsupportedAlert() {
        let alert = UIAlertController(title: "Not supported".localized, message: "This feature is not supported on your device".localized, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default, handler: nil))
        present(vc: alert)
    }
}
