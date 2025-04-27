import SnapKit
import Network
import UIKit
import TVRemoteControl
import ShadowImageButton
import Utilities
import CustomBlurEffectView
import Reachability

// MARK: - Constants

private enum LayoutConstants {
    static let shadowRadius: CGFloat = 14.7
    static let shadowOffset = CGSize(width: 0, height: 4)
    static let shadowOpacity: Float = 0.6
    static let contentInsets = UIEdgeInsets(top: 0, left: 28, bottom: 61, right: 28)
    static let headerCellHeight: CGFloat = 450
    static let deviceCellHeight: CGFloat = 91
    static let infoViewHeight: CGFloat = 240
    static let successInfoViewHeight: CGFloat = 283
    static let buttonCornerRadius: CGFloat = 32
}

// MARK: - View Controller

final class DevicesController: BaseController {

    private var reachability: Reachability?
        
    // MARK: - UI Components
    
    private lazy var backGroundBlurView = CustomBlurEffectView().apply {
        $0.blurRadius = 20
        $0.colorTint = UIColor(hex: "171313")
        $0.colorTintAlpha = 0.3
    }
    
    private lazy var blurView = CustomBlurEffectView().apply {
        $0.blurRadius = 20
        $0.colorTint = UIColor(hex: "171313")
        $0.colorTintAlpha = 0.3
        $0.isHidden = true
    }
    
    private lazy var infoView = InfoActionView().apply {
        $0.onActionButtonTap = { [weak self] in
            self?.blurView.isHidden = true
        }
    }
    
    private lazy var shadowImageView = UIImageView(image: UIImage(named: "devicesShadow")).apply {
        $0.contentMode = .scaleAspectFill
    }
    
    private lazy var closeButton = UIButton().apply {
        $0.setImage(UIImage(named: "close"), for: .normal)
        $0.addTarget(self, action: #selector(handleCloseAction), for: .touchUpInside)
    }
    
    private lazy var guideButton = ShadowImageButton().apply {
        $0.configure(
            buttonConfig: .init(
                title: "Can’t connect".localized,
                font: .font(weight: .bold, size: 18),
                textColor: .white,
                image: UIImage(named: "question"),
                imageSize: CGSize(width: 34, height: 34)
            ),
            backgroundImageConfig: .init(
                image: nil,
                cornerRadius: LayoutConstants.buttonCornerRadius,
                shadowConfig: nil
            )
        )
        $0.backgroundColor = .init(hex: "4E4F5C")
        $0.action = { [weak self] in self?.handleOpenGuide() }
    }
    
    private lazy var tryAgainButton = ShadowImageButton().apply {
        $0.configure(
            buttonConfig: .init(
                title: "Try again".localized,
                font: .font(weight: .bold, size: 18),
                textColor: .white,
                image: nil
            ),
            backgroundImageConfig: .init(
                image: nil,
                cornerRadius: LayoutConstants.buttonCornerRadius,
                shadowConfig: .init(
                    color: UIColor(hex: "117FF5"),
                    opacity: LayoutConstants.shadowOpacity,
                    offset: LayoutConstants.shadowOffset,
                    radius: LayoutConstants.shadowRadius
                )
            )
        )
        $0.backgroundColor = .init(hex: "0055F1")
        $0.action = { [weak self] in self?.handleTryAgainAction() }
        $0.isHidden = true
    }
    
    private lazy var tableView = UITableView().apply {
        $0.register(DeviceCell.self, forCellReuseIdentifier: DeviceCell.reuseID)
        $0.register(DeviceSearchCell.self, forCellReuseIdentifier: DeviceSearchCell.reuseID)
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.contentInset = calculateContentInset()
    }
    
    // MARK: - Properties
    
    private let viewModel = DevicesViewModel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        setupViewHierarchy()
        setupControllerConstraints()
        setupObservers()
        
        reachability = try? Reachability()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability?.startNotifier()
        } catch {
            print("could not start reachability notifier")
        }
        
        LocalNetworkAuthorization().requestAuthorization { granted in
            DispatchQueue.main.async {
                if granted {
                    self.viewModel.startSearch()
                } else {
                    self.presentCrossDissolve(vc: AccessViewController(type: .localNetwork))
                }
            }
        }
    }
    
    deinit {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
    
    // MARK: - Private Methods
    
    private func configureNavigation() {
        configurNavigation(rightView: closeButton)
    }
    
    private func setupViewHierarchy() {
        
        view.insertSubview(backGroundBlurView, at: 0)
        
        backGroundBlurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubviews(tableView, shadowImageView, tryAgainButton, guideButton, blurView)
        blurView.addSubview(infoView)
    }
    
    private func setupControllerConstraints() {
        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        infoView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(LayoutConstants.infoViewHeight)
            $0.width.equalTo(296)
        }
        
        shadowImageView.snp.makeConstraints {
            $0.bottom.horizontalEdges.equalToSuperview()
            $0.height.equalTo(UIScreen.isLittleDevice ? 70 : 132)
        }
        
        tryAgainButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.height.equalTo(62)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(109)
        }
        
        guideButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.height.equalTo(64)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(25)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom).offset(20)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tryAgainButton.addButtonInnerShadow()
        }
    }
    
    private func calculateContentInset() -> UIEdgeInsets {
        return UIEdgeInsets(
            top: 50,
            left: 0,
            bottom: 150,
            right: 0
        )
    }
    
    private func setupObservers() {
        viewModel.onUpdate = { [weak self] in
            self?.updateUI()
        }
        
        viewModel.onConnected = { [weak self] in
            self?.showConnectionSuccess()
        }
        
        viewModel.onConnecting = { [weak self] in
            self?.showConnectingState()
        }
        
        viewModel.onConnectionError = { [weak self] in
            self?.showConnectionError()
        }
        
        viewModel.onNotFound = { [weak self] in
            self?.showNoDevicesFound()
        }
    }
    
    private func updateUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            let isEmpty = viewModel.devices.isEmpty
            shadowImageView.isHidden = isEmpty
            tryAgainButton.isHidden = true
            
            if !isEmpty {
                tableView.contentInset = UIEdgeInsets(top: UIScreen.isLittleDevice ? -80 : 0, left: 0, bottom: 100, right: 0)
            }
            
            tableView.reloadData()
        }
    }
    
    private func showConnectionSuccess() {
        DispatchQueue.main.async { [weak self] in
            
            self?.blurView.isHidden = false
            self?.infoView.configure(
                image: UIImage(named: "success"),
                title: "Synced to TV".localized,
                subtitle: self?.viewModel.connectedDevice?.name
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self?.blurView.isHidden = true
            }
        }
    }
    
    private func showConnectingState() {
        DispatchQueue.main.async { [weak self] in
            
            self?.blurView.isHidden = false
            self?.infoView.configure(
                image: nil,
                title: "Syncing...".localized,
                subtitle: self?.viewModel.connectedDevice?.name
            )
        }
    }
    
    private func showConnectionError() {
        DispatchQueue.main.async { [weak self] in
            
            self?.blurView.isHidden = false
            self?.infoView.configure(
                image: UIImage(named: "error"),
                title: "No sync".localized,
                subtitle: self?.viewModel.connectedDevice?.name
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self?.blurView.isHidden = true
            }
        }
    }
    
    private func showNoDevicesFound() {
        DispatchQueue.main.async { [weak self] in
            self?.tryAgainButton.isHidden = false
            self?.tableView.reloadData()
        }
    }
    
    private func generateHapticFeedback() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    // MARK: - Actions
    
    @objc private func handleTryAgainAction() {
        generateHapticFeedback()
        viewModel.startSearch()
    }
    
    @objc private func handleCloseAction() {
        generateHapticFeedback()
        dismiss(animated: true)
    }
    
    @objc private func handleOpenGuide() {
        generateHapticFeedback()
        presentCrossDissolve(vc: FAQController())
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            break
        case .cellular, .unavailable:
            self.presentCrossDissolve(vc: AccessViewController(type: .wifi))
        }
    }
}

// MARK: - UITableViewDataSource & Delegate

extension DevicesController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : viewModel.devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: DeviceSearchCell.reuseID,
                for: indexPath
            ) as! DeviceSearchCell
            cell.configure(isNotFound: viewModel.devicesNotFound)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: DeviceCell.reuseID,
            for: indexPath
        ) as! DeviceCell
        cell.configure(tv: viewModel.devices[indexPath.row])
        return cell
    }
}

extension DevicesController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        generateHapticFeedback()
        viewModel.connect(device: viewModel.devices[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0 ? LayoutConstants.headerCellHeight : LayoutConstants.deviceCellHeight
    }
}
