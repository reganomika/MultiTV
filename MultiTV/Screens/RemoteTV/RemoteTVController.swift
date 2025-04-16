import UIKit
import Utilities

final class RemoteTVController: BaseController {
    
    // MARK: - UI Components
    
    private lazy var navigationTitleLabel = UILabel().apply {
        $0.text = "Not connected".localized
        $0.font = .font(weight: .bold, size: 25)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
    }
    
    private func configureNavigation() {
        configurNavigation(leftView: navigationTitleLabel)
    }
}
