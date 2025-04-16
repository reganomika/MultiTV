import UIKit
import Utilities

final class SettingsController: BaseController {
    
    // MARK: - UI Components
    
    private lazy var navigationTitleLabel = UILabel().apply {
        $0.text = "Settings".localized
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
