import SnapKit
import UIKit
import RxSwift
import PremiumManager
import CustomBlurEffectView
import Combine
import Utilities
import TVRemoteControl
import ShadowImageButton

private enum Constants {
    static let buttonCornerRadius: CGFloat = 31
    static let shadowRadius: CGFloat = 14.7
    static let shadowOffset = CGSize(width: 0, height: 4)
    static let shadowOpacity: Float = 0.6
}

final class AppsController: BaseController {
    
    // MARK: - UI Components
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "appsBackground"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var navigationTitleLabel = UILabel().apply {
        $0.text = "Apps".localized
        $0.font = .font(weight: .bold, size: 25)
    }
    
    private lazy var connectionImageView = UIImageView(image: UIImage(named: "appsConnection")).apply {
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var connectionTitleLabel = UILabel().apply {
        $0.font = .font(weight: .bold, size: 25)
        $0.text = "Apps are locked".localized
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private lazy var connectionSubtitleLabel = UILabel().apply {
        $0.attributedText = "Plug in your TV to unlock these apps".localized.attributedString(
            font: .font(weight: .semiBold, size: 18),
            aligment: .center,
            color: UIColor.white.withAlphaComponent(0.65),
            lineSpacing: 5,
            maxHeight: 50
        )
        $0.numberOfLines = 0
    }
    
    private lazy var connectionStackView = UIStackView(arrangedSubviews: [
        connectionTitleLabel,
        connectionSubtitleLabel
    ]).apply {
        $0.axis = .vertical
        $0.spacing = 15
    }
    
    private lazy var connectButton = ShadowImageButton().apply {
        $0.configure(
            buttonConfig: .init(
                title: "Sync with TV".localized,
                font: .font(weight: .bold, size: 18),
                textColor: .white,
                image: nil
            ),
            backgroundImageConfig: .init(
                image: nil,
                cornerRadius: Constants.buttonCornerRadius,
                shadowConfig: .init(
                    color: UIColor(hex: "117FF5"),
                    opacity: Constants.shadowOpacity,
                    offset: Constants.shadowOffset,
                    radius: Constants.shadowRadius
                )
            )
        )
        $0.backgroundColor = .init(hex: "0055F1")
        $0.action = { [weak self] in self?.handleConnectAction() }
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        collectionView.register(AppCell.self, forCellWithReuseIdentifier: "AppCell")
        return collectionView
    }()
    
    private let viewModel = AppsViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        configureViewHierarchy()
        setupObservers()
    }
    
    private func configureNavigation() {
        configurNavigation(leftView: navigationTitleLabel)
    }
    
    private func configureViewHierarchy() {
        view.insertSubview(backgroundImageView, at: 0)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubviews(
            connectionImageView,
            connectionStackView,
            connectButton,
            collectionView
        )
        
        connectionImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-50)
            $0.horizontalEdges.equalToSuperview()
        }
        
        connectionStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(connectionImageView.snp.bottom).inset(-14)
            $0.horizontalEdges.equalToSuperview().inset(50)
        }
        
        connectButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(84)
            $0.height.equalTo(56)
            $0.top.equalTo(connectionStackView.snp.bottom).inset(-28)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(25)
            $0.bottom.equalToSuperview()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.connectButton.addButtonInnerShadow()
        }
    }
    
    private func setupObservers() {
        SamsungTVConnectionService.shared.connectionStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.updateUI(forConnectionStatus: isConnected)
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(forConnectionStatus isConnected: Bool) {
        connectionImageView.isHidden = isConnected
        connectButton.isHidden = isConnected
        connectionStackView.isHidden = isConnected
        collectionView.isHidden = !isConnected
        collectionView.reloadData()
    }
    
    // MARK: - Actions
    
    @objc private func handleConnectAction() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        presentCrossDissolve(vc: DevicesController())
    }
}

extension AppsController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.availableApps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AppCell", for: indexPath) as? AppCell else {
            return UICollectionViewCell()
        }
        let app = viewModel.availableApps[indexPath.row]
        cell.configure(app: app)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let availableWidth = collectionView.frame.width - 16
        let cellWidth = (availableWidth / 3).rounded(.down)
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        let selectedApp = viewModel.availableApps[indexPath.row]
        
        viewModel.launchApplication(selectedApp)
    }
}
