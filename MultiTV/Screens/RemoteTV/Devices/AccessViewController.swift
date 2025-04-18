import SnapKit
import UIKit
import TVRemoteControl
import ShadowImageButton
import Utilities
import CustomBlurEffectView
import Reachability

enum AccessType {
    case wifi
    case localNetwork
}

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

final class AccessViewController: BaseController {
    
    private var reachability: Reachability?
    
    // MARK: - UI Components
    
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
    
    private lazy var closeButton = UIButton().apply {
        $0.setImage(UIImage(named: "close"), for: .normal)
        $0.addTarget(self, action: #selector(handleCloseAction), for: .touchUpInside)
    }
    
    private lazy var openSettingsButton = ShadowImageButton().apply {
        $0.configure(
            buttonConfig: .init(
                title: "Open Settings".localized,
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
        $0.action = { [weak self] in self?.handleOpenSettings() }
    }
    
        
    // MARK: - Lifecycle
    
    private let type: AccessType
    
    init(type: AccessType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        setupViewHierarchy()
        setupControllerConstraints()
        showUI()
        
        if type == .localNetwork {
            LocalNetworkAuthorization().requestAuthorization { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.handleCloseAction()
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if type == .localNetwork {
            
        } else {
            
            NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
            do {
                try reachability?.startNotifier()
            } catch {
                print("could not start reachability notifier")
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
        
        view.insertSubview(blurView, at: 0)
        
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubviews(openSettingsButton)
        blurView.addSubview(infoView)
    }
    
    private func setupControllerConstraints() {
        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        infoView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(LayoutConstants.infoViewHeight)
            $0.width.equalTo(296)
        }
        
        openSettingsButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.height.equalTo(62)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(25)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.openSettingsButton.addButtonInnerShadow()
        }
    }
    
    private func showUI() {
        DispatchQueue.main.async { [weak self] in
            
            self?.blurView.isHidden = false
            self?.infoView.configure(
                customBigImage: UIImage(named: self?.type == .wifi ? "wifi" : "localNetwork"),
                image: nil,
                title: self?.type == .wifi ? "Wi-Fi required".localized : "Turn on local network access".localized,
                subtitle:self?.type == .wifi ? "Your phone needs to be on a Wi-Fi network".localized : "Enable local network access to scan for and link with your TV".localized
            )
        }
    }
    
    private func generateHapticFeedback() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    // MARK: - Actions
    
    @objc private func handleOpenSettings() {
        generateHapticFeedback()
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)

    }
    
    @objc private func handleCloseAction() {
        generateHapticFeedback()
        dismiss(animated: true)
    }
    
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            handleCloseAction()
        case .cellular, .unavailable:
            break
        }
    }
}
