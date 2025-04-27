import Foundation
import TVRemoteControl
import TVCommanderKit
import TVDiscovery

enum DeviceType: Codable {
    case fireStick
    case samsungTV
    case rokutv
    case lg
}

struct Device: Codable {
    let name: String
    let address: String?
    let samsungTvModel: SamsungTVModel?
    let type: DeviceType
}

final class DevicesViewModel {
    
    private var serviceTypes: [String] = [
        "_amzn-wplay._tcp",
        "_airplay._tcp."
    ]
    
    private lazy var discoveryService = TVDiscoveryService(serviceTypes: serviceTypes)
    
    var devices: [Device] = []
    
    let amazonManager = FireStickControl.shared
    
    let tvSearcher = TVSearcher()
    var samsungTV: SamsungTV?
    let connectionManager = SamsungTVConnectionService.shared
        
    var connectedDevice: Device?
    
    var devicesNotFound = false
    
    var onUpdate: (() -> Void)?
    var onConnectionError: (() -> Void)?
    var onConnected: (() -> Void)?
    var onConnecting: (() -> Void)?
    var onNotFound: (() -> Void)?
    
    init() {
      
        setupSubscriptions()
    }
    
    func setupSubscriptions() {
        
        tvSearcher.addSearchObserver(self)
        
        discoveryService.onDeviceDiscovered = { [weak self] (device, ip) in
            guard let self else { return }
            
            if device.contains("amzn") {
                self.amazonManager.fetchDeviceInfo(ip: ip) { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success(let deviceInfo):
                        if self.devices.map({ $0.address }).contains(ip) == false {
                            
                            let newDevice = Device(name: deviceInfo.friendlyName, address: ip, samsungTvModel: nil, type: .fireStick)
                            self.devices.append(newDevice)
                            devicesNotFound = false
                            onUpdate?()
                        }
                        
                    case .failure:
                        break
                    }
                }
            } else if isLGTV(name: device) {
                let newDevice = Device(name: formatTVName(device), address: ip, samsungTvModel: nil, type: .lg)
                self.devices.append(newDevice)
                devicesNotFound = false
                onUpdate?()
            }

        }
        
        discoveryService.onScanFinished = { [weak self] in
            guard let self else { return }
            self.tvSearcher.stopSearch()
            if self.devices.isEmpty {
                self.devicesNotFound = true
                self.onNotFound?()
            } else {
                self.onUpdate?()
            }
        }
    }
    
    func startSearch() {
        devicesNotFound = false
        devices.removeAll()
        onUpdate?()
        tvSearcher.startSearch()
        discoveryService.start()
    }
    
    func connect(device: Device) {
        
        switch device.type {
        case .fireStick:
            connectToFireStick(device: device)
        case .samsungTV:
            if let samsungTVDevice = device.samsungTvModel {
                connectToSamsung(device: device)
            }
        case .rokutv:
            connectToRoku(device: device)
        case .lg:
            connectToLG(device: device)
        }
  
    }
    
    private func connectToSamsung(device: Device) {
        guard let samsungDevice = device.samsungTvModel else {
            onConnectionError?()
            return
        }
        connectedDevice = device
        do {
            samsungTV = try SamsungTV(tv: samsungDevice, appName: Config.appName)
            samsungTV?.delegate = self
            samsungTV?.connectToTV()
            onConnecting?()
        } catch {
            onConnectionError?()
        }
    }
    
    private func connectToLG(device: Device) {
        
    }
    
    private func connectToFireStick(device: Device) {
        
    }
    
    private func connectToRoku(device: Device) {
        
    }
    
    private func isLGTV(name: String) -> Bool {
        return name.lowercased().contains("lg")
    }

    private func formatTVName(_ input: String) -> String {
        let result = input.replacingOccurrences(of: "\\[LG\\]\\s*webOS\\s*TV\\s*", with: "LG ", options: .regularExpression)
        return result
    }
}

extension DevicesViewModel: TVSearchObserving {

    func tvSearchDidStart() {}
    
    func tvSearchDidStop() {}
    
    func tvSearchDidFindTV(_ tv: TVCommanderKit.TV) {
        
        if devices.map({ $0.address }).contains(tv.device?.ip) {
            return
        }
        
        let newDevice = Device(name: tv.name.decodingHTMLEntities(), address: tv.device?.ip, samsungTvModel: tv.map(), type: .samsungTV)
        
        devices.append(newDevice)
        devicesNotFound = false
        onUpdate?()
    }
    
    func tvSearchDidLoseTV(_ tv: TVCommanderKit.TV) {}
}

extension DevicesViewModel: SamsungTVDelegate {
    
    func samsungTVDidConnect(_ samsungTV: SamsungTV) {}
    
    func samsungTVDidDisconnect(_ samsungTV: SamsungTV) {}
    
    func samsungTV(_ samsungTV: SamsungTV, didUpdateAuthState authStatus: SamsungTVAuthStatus) {
        switch authStatus {
        case .allowed:
            
            if let connectedDevice {
                
                guard let samsungDevice = connectedDevice.samsungTvModel else {
                    onConnectionError?()
                    return
                }
                
                Storage.shared.saveConnectedDevice(connectedDevice)
                connectionManager.connect(to: samsungDevice, appName: Config.appName, commander: samsungTV)
                onConnected?()
                onUpdate?()
            }
        case .denied, .none:
            onConnectionError?()
        }
    }
    
    func samsungTV(_ samsungTV: SamsungTV, didWriteRemoteCommand command: SamsungTVRemoteCommand) {}
    
    func samsungTV(_ samsungTV: SamsungTV, didEncounterError error: SamsungTVError) {}
}

extension TVCommanderKit.TV.Device {
    func map() -> SamsungTVModel.Device {
        SamsungTVModel.Device.init(
            countryCode: self.countryCode,
            deviceDescription: self.deviceDescription,
            developerIp: self.developerIp,
            developerMode: self.developerMode,
            duid: self.duid,
            firmwareVersion: self.firmwareVersion,
            frameTvSupport: self.frameTvSupport,
            gamePadSupport: self.gamePadSupport,
            id: self.id,
            imeSyncedSupport: self.imeSyncedSupport,
            ip: self.ip,
            language: self.language,
            model: self.model,
            modelName: self.modelName,
            name: self.name,
            networkType: self.networkType,
            os: self.os,
            powerState: self.powerState,
            resolution: self.resolution,
            smartHubAgreement: self.smartHubAgreement,
            ssid: self.ssid,
            tokenAuthSupport: self.tokenAuthSupport,
            type: self.type,
            udn: self.udn,
            voiceSupport: self.voiceSupport,
            wallScreenRatio: self.wallScreenRatio,
            wallService: self.wallService,
            wifiMac: self.wifiMac
        )
    }
}

extension TVCommanderKit.TV {
    func map() -> SamsungTVModel {
        return SamsungTVModel.init(
            device: self.device?.map(),
            id: self.id,
            isSupport: self.isSupport,
            name: self.name,
            remote: self.remote,
            type: self.type,
            uri: self.uri,
            version: self.version
        )
    }
}
