import UIKit
import UniversalTVRemote

// MARK: - View Model

final class AppsViewModel {
    
    // MARK: - Dependencies
    
    private let appLauncher = SamsungTVAppManager()
    private let amazonManager = FireStickControl.shared
    private let samsungManager = SamsungTVConnectionService.shared
    private let lgManager = LGTVManager.shared
    private let rokuManager = RokuDeviceManager.shared
    
    // MARK: - Properties
    
    private(set) var samsungApps: [SamsungTVApp] = SamsungTVApp.allApps()
    private(set) var amazonApps: [FireStickApp] = []
    private(set) var lgApps: [LGRemoteControlResponseApplication] = []
    private(set) var rokuApps: [RokuApp] = []
    
    var onUpdate: (() -> Void)?
    
    
    // MARK: - Public Methods
    
    func updateLGApps(lgApps: [LGRemoteControlResponseApplication]) {
        self.lgApps = lgApps.filter({ LGApp.init(rawValue: $0.id) != .unknown })
    }
    
    func updateRokuApps(apps: [RokuApp]) {
        self.rokuApps = apps
        self.onUpdate?()
    }
    
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
    
    func launchLGApp(_ app: LGRemoteControlResponseApplication) {
        if let id = app.id {
            lgManager.sendCommand(.launchApp(appId: id))
        }
    }
    
    func launchRokuApp(_ app: RokuApp) {
        guard let device = Storage.shared.restoreConnectedDevice(), device.type == .rokutv else {
            return
        }

        rokuManager.launchApp(withId: app.id, ipAddress: device.address)
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

enum LGApp: String, CaseIterable {
    case netflix
    case appleTV
    case youtube
    case amazon
    case spotify
    case unknown
    
    init?(rawValue: String?) {
        switch rawValue {
        case "netflix":
            self = .netflix
        case "com.apple.appletv":
            self = .appleTV
        case "youtube.leanback.v4":
            self = .youtube
        case "spotify":
            self = .spotify
        case "amazon":
            self = .amazon
        default:
            self = .unknown
        }
    }
    
    var image: UIImage? {
        switch self {
        case .netflix:
            return UIImage(named: "netflix")
        case .appleTV:
            return UIImage(named: "appleTV")
        case .youtube:
            return UIImage(named: "youtube")
        case .spotify:
            return UIImage(named: "spotify")
        case .amazon:
            return UIImage(named: "amazon")
        default:
            return UIImage(named: "placeholder")
        }
    }
}
