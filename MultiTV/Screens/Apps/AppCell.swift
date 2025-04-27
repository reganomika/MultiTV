import UIKit
import SnapKit
import UniversalTVRemote
import SDWebImage
import Combine

class AppCell: UICollectionViewCell {
    
    private let rokuManager = RokuDeviceManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 13
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        clipsToBounds = true
        layer.cornerRadius = 10
        contentView.addSubview(imageView)
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    func configure(lg: LGRemoteControlResponseApplication) {
        if let id = lg.id {
            
            switch id {
            case "netflix":
                imageView.image = UIImage(named: "netflix")
            case "com.apple.appletv":
                imageView.image = UIImage(named: "appleTV")
            case "youtube.leanback.v4":
                imageView.image = UIImage(named: "youtube")
            case "spotify":
                imageView.image = UIImage(named: "spotify")
            case "amazon":
                imageView.image = UIImage(named: "prime")
            default:
                imageView.image = UIImage(named: "placeholder")
            }
        }
    }
    
    func configure(samsung: SamsungTVApp) {
        imageView.image = samsung.iconImage
    }
    
    func configure(amazon: FireStickApp) {
        imageView.sd_setImage(with: URL(string: amazon.iconArtSmallUri))
    }
    
    func configure(roku: RokuApp) {
        guard let device = Storage.shared.restoreConnectedDevice(), device.type == .rokutv else {
            return
        }
        
        self.rokuManager.fetchAppIcon(appId: roku.id, ipAddress: device.address)
            .sink(receiveCompletion: { _ in }, receiveValue: { image in
                self.imageView.image = image
            })
            .store(in: &self.cancellables)
    }
}
