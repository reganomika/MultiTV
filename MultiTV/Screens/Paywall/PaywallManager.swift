import UIKit
import PremiumManager

final class PaywallManager {
    static let shared = PaywallManager()
    
    func getPaywall(isFromOnboarding: Bool = false) -> UIViewController {
        
        switch PremiumManager.shared.paywallType.value {
        case .first:
            let vc = PaywallNewController(isFromOnboarding: isFromOnboarding)
            vc.modalPresentationStyle = .fullScreen
            return vc
        case .second:
            let vc = PaywallOldController(isFromOnboarding: isFromOnboarding)
            vc.modalPresentationStyle = .fullScreen
            return vc
        }
    }
}
