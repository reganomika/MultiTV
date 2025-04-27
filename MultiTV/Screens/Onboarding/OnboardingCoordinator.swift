import UIKit
import Utilities

class OnboardingCoordinator {
    
    private let window: UIWindow
    private var currentIndex = 0
    private let models: [OnboardingModel]
    
    init(window: UIWindow) {
        self.window = window
        self.models = [
            OnboardingModel(
                image: UIImage(named: UIScreen.isLittleDevice ? "onboarding_0" : "onboarding_0"),
                title: "Universal Remote Control for TV".localized,
                higlitedText: "Universal Remote".localized,
                subtitle: "Control your TV like a traditional remote with features like volume adjustment".localized,
                rating: false
            ),
            OnboardingModel(
                image: UIImage(named: UIScreen.isLittleDevice ? "onboarding_1" : "onboarding_1"),
                title: "App & Media Control".localized,
                higlitedText: "App & Media".localized,
                subtitle: "Easily launch and switch between your favorite apps, stream content".localized,
                rating: false
            ),
            OnboardingModel(
                image: UIImage(named: UIScreen.isLittleDevice ? "onboarding_2" : "onboarding_2"),
                title: "Universal Compatibility".localized,
                higlitedText: "Compatibility".localized,
                subtitle: "Supports a wide range of TV models. No need for multiple remotes!".localized,
                rating: true
            ),
            OnboardingModel(
                image: UIImage(named: UIScreen.isLittleDevice ? "onboarding_3" : "onboarding_3"),
                title: "App & Media Control".localized,
                higlitedText: "App & Media".localized,
                subtitle: "Thank you for choosing Universal Remote TV — we’re excited to hear from you!".localized,
                rating: false
            )
        ]
    }
    
    func start() {
        showNextViewController()
    }
    
    private func showNextViewController() {
        guard currentIndex < models.count else {
            transitionToPaywall()
            return
        }
        
        let model = models[currentIndex]
        let viewController = OnboardingController(model: model, coordinator: self)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        
        currentIndex += 1
    }
    
    func goToNextScreen() {
        showNextViewController()
    }
    
    private func transitionToPaywall() {
        let vc = PaywallManager.shared.getPaywall(isFromOnboarding: true)
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }
}
