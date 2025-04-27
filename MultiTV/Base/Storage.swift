import Foundation
import StorageManager
import TVRemoteControl

final class Storage {

    // MARK: - Properties
    
    static let shared = Storage()

    private let storageManager: StorageManager = .shared

    // MARK: - Public Properties

    var needSkipOnboarding: Bool {
        get { storageManager.get(forKey: onboardingShownKey, defaultValue: false) }
        set { storageManager.set(newValue, forKey: onboardingShownKey) }
    }

    var wasRevviewScreen: Bool {
        get { storageManager.get(forKey: reviewShownKey, defaultValue: false) }
        set { storageManager.set(newValue, forKey: reviewShownKey) }
    }
    
    var buttonsTapNumber: Int {
        get { storageManager.get(forKey: userActionCounterKey, defaultValue: 0) }
        set { storageManager.set(newValue, forKey: userActionCounterKey) }
    }
    
    private let deviceKey = "ConnectedTVDevice"
    private let onboardingShownKey = "onboarding_key_dataBase"
    private let reviewShownKey = "review_key_dataBase"
    private let userActionCounterKey = "user_actions_key_dataBase"
    
    func saveConnectedDevice(_ device: Device?) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(device) {
            UserDefaults.standard.set(encoded, forKey: deviceKey)
        }
    }
    
    func restoreConnectedDevice() -> Device? {
        if let savedDevice = UserDefaults.standard.data(forKey: deviceKey) {
            let decoder = JSONDecoder()
            if let device = try? decoder.decode(Device.self, from: savedDevice) {
                return device
            }
        }
        return nil
    }
}
