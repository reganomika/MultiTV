import UIKit
import TVRemoteControl

// MARK: - View Model

final class AppsViewModel {
    
    // MARK: - Dependencies
    
    private let appLauncher = SamsungTVAppManager()
    private let amazonManager = FireStickControl.shared
    private let samsungManager = SamsungTVConnectionService.shared
    
    // MARK: - Properties
    
    private(set) var samsungApps: [SamsungTVApp] = SamsungTVApp.allApps()
    private(set) var amazonApps: [FireStickApp] = []
    
    var onUpdate: (() -> Void)?
    
    
    // MARK: - Public Methods
    
    func getApps(ip: String, token: String?) {
        amazonManager.getApps(
            ip: ip,
            token: token
        ) { [weak self] result in
            self?.amazonApps = (try? result.get()) ?? []
            self?.onUpdate?()
        }
    }
    
    func launchSamsungApp(_ app: SamsungTVApp) {
        
        if let ipAddress = samsungManager.connectedDevice?.ipAddress {
            Task {
                try await appLauncher.launch(tvApp: app, tvIPAddress: ipAddress)
            }
        }
    }
    
    func launchAmanzonApp(_ app: FireStickApp, ip: String, token: String?) {
        amazonManager.openApp(
            app: app,
            ip: ip,
            token: token
        )
    }
}

// MARK: - Error Handling

extension AppsViewModel {
    enum ApplicationError: Error {
        case deviceNotConnected
    }
}

// MARK: - TVApp Extension

extension SamsungTVApp {
    var iconImage: UIImage? {
        let appIcons: [String: String] = [
            "ESPN": "espn",
            "Hulu": "hulu",
            "Max": "max",
            "Netflix": "netflix",
            "Paramount +": "paramount",
            "Pluto TV": "pluto",
            "Prime Video": "prime",
            "Spotify": "spotify",
            "YouTube": "youtube"
        ]
        
        return appIcons[name].flatMap { UIImage(named: $0) }
    }
}
