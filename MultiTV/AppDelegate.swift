import UIKit
//import FirebaseCore
import UniversalTVRemote
import PremiumManager

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let connectionManager = SamsungTVConnectionService.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        FirebaseApp.configure()
        FireStickControl.shared.configure(apiKey: Config.amazonApiKey)
        PremiumManager.shared.configure(with: .init(apiKey: Config.apphudKey, debugMode: Config.debugMode))
        PremiumManager.shared.fetchProducts()
        Storage.shared.saveConnectedDevice(nil)
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }

        application.registerForRemoteNotifications()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        PremiumManager.shared.submitPushNotificationsToken(deviceToken: deviceToken)
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {}
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        PremiumManager.shared.handlePushNotification(notification: response.notification)
        completionHandler()
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        PremiumManager.shared.handlePushNotification(notification: notification)
        completionHandler([])
    }
}
