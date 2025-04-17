import Foundation
import TVRemoteControl
import TVCommanderKit

final class DevicesViewModel {
    
    var devices: [SamsungTVModel] = []
    
    let tvSearcher = TVSearcher()
    var samsungTV: SamsungTV?
    let connectionManager = SamsungTVConnectionService.shared
        
    var connectedDevice: SamsungTVModel?
    
    var devicesNotFound = false
    
    var onUpdate: (() -> Void)?
    var onConnectionError: (() -> Void)?
    var onConnected: (() -> Void)?
    var onConnecting: (() -> Void)?
    var onNotFound: (() -> Void)?
    
    init() {
        tvSearcher.addSearchObserver(self)
    }
    
    func startSearch() {
        devicesNotFound = false
        devices.removeAll()
        onUpdate?()
        tvSearcher.startSearch()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.tvSearcher.stopSearch()
            if self.devices.isEmpty {
                self.devicesNotFound = true
                self.onNotFound?()
            } else {
                self.onUpdate?()
            }
        }
    }
    
    func connect(device: SamsungTVModel) {
        connectedDevice = device
        do {
            samsungTV = try SamsungTV(tv: device, appName: Config.appName)
            samsungTV?.delegate = self
            samsungTV?.connectToTV()
            onConnecting?()
        } catch {
            onConnectionError?()
        }
    }
    
    func cancelConnection() {
        samsungTV?.disconnectFromTV()
    }
}

extension DevicesViewModel: TVSearchObserving {

    func tvSearchDidStart() {}
    
    func tvSearchDidStop() {}
    
    func tvSearchDidFindTV(_ tv: TVCommanderKit.TV) {
        
        if devices.map({ $0.id }).contains(tv.id) {
            return
        }
        
        devices.append(tv.map())
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
                Storage.shared.saveConnectedDevice(connectedDevice)
                connectionManager.connect(to: connectedDevice, appName: Config.appName, commander: samsungTV)
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
