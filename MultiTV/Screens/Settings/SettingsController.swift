import SnapKit
import UIKit
import RxSwift
import PremiumManager
import CustomBlurEffectView
import Combine
import Utilities
import SafariServices

class SettingsController: BaseController {
    private let contentProvider = SettingsContentProvider()
    private let tableView = UITableView()
    private let navigationTitle = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewHierarchy()
        configureContentProvider()
        configureNavigation()
    }
    
    private func configureViewHierarchy() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        
        tableView.register(
            PremiumCell.self,
            forCellReuseIdentifier: PremiumCell.reuseID
        )
        tableView.register(
            BaseCell.self,
            forCellReuseIdentifier: BaseCell.reuseID
        )
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 100
        tableView.showsVerticalScrollIndicator = false
    }
    
    private func configureContentProvider() {
        contentProvider.delegate = self
        contentProvider.rebuildMenu(forPremiumStatus: PremiumManager.shared.isPremium.value)
    }
    
    private func configureNavigation() {
        navigationTitle.text = "Settings".localized
        navigationTitle.font = .font(weight: .bold, size: 25)
        configurNavigation(leftView: navigationTitle)
    }
}

extension SettingsController: SettingsContentUpdatable {
    func settingsContentDidChange() {
        tableView.reloadData()
    }
}

extension SettingsController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentProvider.currentRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch contentProvider.currentRows[indexPath.row] {
        case .premiumPromotion:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PremiumCell.reuseID,
                for: indexPath
            ) as! PremiumCell
            return cell
            
        case .standardOption(let option):
            let cell = tableView.dequeueReusableCell(
                withIdentifier: BaseCell.reuseID,
                for: indexPath
            ) as! BaseCell
            cell.configure(type: option)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        switch contentProvider.currentRows[indexPath.row] {
        case .premiumPromotion:
            presentPremiumPaywall()
            
        case .standardOption(let option):
            handleMenuOptionSelection(option)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch contentProvider.currentRows[indexPath.row] {
        case .premiumPromotion: return UITableView.automaticDimension
        case .standardOption: return 89
        }
    }
    
    private func handleMenuOptionSelection(_ option: SettingsOption) {
        switch option {
        case .shareApp:
            presentShareSheet()
        case .privacyPolicy:
            presentWebView(urlString: Config.privacy)
        case .termsOfService:
            presentWebView(urlString: Config.terms)
        case .alternateIcons:
            presentIconSelection()
        case .faq:
            presentFaq()
        }
    }
    
    private func presentShareSheet() {
        let appStoreURL = URL(string: "https://apps.apple.com/us/app/\(Config.appId)")!
        let activityVC = UIActivityViewController(activityItems: [appStoreURL], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = view
        present(activityVC, animated: true)
    }
    
    private func presentWebView(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    
    private func presentPremiumPaywall() {
//        let vc = PaywallViewController(
//            interactor: OnboardingInteractor(
//                coordinator: OnboardingCoordinator(window: nil)
//            )
//        )
//        present(vc: vc)
    }
    
    private func presentFaq() {
        push(vc: FAQController())
    }
    
    private func presentIconSelection() {
        presentCrossDissolve(vc: ReplaceIconController())
    }
}
