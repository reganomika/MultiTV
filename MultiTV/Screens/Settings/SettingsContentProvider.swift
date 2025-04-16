import Combine
import PremiumManager
import UIKit
import Foundation
import Utilities
import RxSwift

protocol SettingsOptionRepresentable {
    var iconAsset: UIImage? { get }
    var displayTitle: String { get }
}

enum SettingsOption: SettingsOptionRepresentable {
    case faq
    case shareApp
    case privacyPolicy
    case termsOfService
    case alternateIcons
    
    var iconAsset: UIImage? {
        switch self {
        case .faq: return UIImage(named: "faq")
        case .shareApp: return UIImage(named: "share")
        case .privacyPolicy: return UIImage(named: "privacy")
        case .termsOfService: return UIImage(named: "terms")
        case .alternateIcons: return UIImage(named: "changeIcon")
        }
    }
    
    var displayTitle: String {
        switch self {
        case .faq: return "FAQ".localized
        case .shareApp: return "Share with other".localized
        case .privacyPolicy: return "Privacy Policy".localized
        case .termsOfService: return "Terms of Use".localized
        case .alternateIcons: return "Replace icon".localized
        }
    }
}

enum SettingsRowConfiguration {
    case premiumPromotion
    case standardOption(SettingsOption)
}

// MARK: - View Model

protocol SettingsContentUpdatable: AnyObject {
    func settingsContentDidChange()
}

class SettingsContentProvider {
    weak var delegate: SettingsContentUpdatable?
    
    private let disposeBag = DisposeBag()
    
    private(set) var currentRows: [SettingsRowConfiguration] = []
    
    init() {
        setupPremiumSubscription()
    }
    
    func rebuildMenu(forPremiumStatus isPremium: Bool = false) {
        currentRows.removeAll()
        
        if !isPremium {
            currentRows.append(.premiumPromotion)
        }
        
        let standardOptions: [SettingsOption] = [
            .faq,
            .alternateIcons,
            .shareApp,
            .privacyPolicy,
            .termsOfService
        ]
        
        currentRows += standardOptions.map { .standardOption($0) }
        delegate?.settingsContentDidChange()
    }
    
    private func setupPremiumSubscription() {
        
        PremiumManager.shared.isPremium
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { isPremium in
                self.rebuildMenu(forPremiumStatus: isPremium)
            })
            .disposed(by: disposeBag)
    }
}

