import Foundation
// swiftlint:disable type_body_length

@objc
protocol ServiceProviderObjCBridgeDelegate: AnyObject {
    func getDeviceInfo(extended: Bool) -> [String: Any]
    func didCompleteInit(_ config: [String: Any])
    func didReceivePrivacy(_ privacy: [String: Any])
    func getValueFromJSONStorage(for key: String) -> Any?
    func setValueToJSONStorage(_ value: Any?, for key: String)
    func deleteKeyFromJSONStorage(for key: String)
    func storageContent() -> [String: Any]
}

@objc
final class ServiceProviderObjCBridge: NSObject {

    private(set) weak var delegate: ServiceProviderObjCBridgeDelegate?

    var serviceProvider = UnityAdsServiceProvider(skdSettingsStorage: .init()) {
        didSet {
            // this is required only for tests until we have objc legacy code and swift
            subscribeDelegate()
        }
    }

    @objc
    var mainNetworkLayer: NetworkLayerObjCBridge {
        NetworkLayerObjCBridge(network: serviceProvider.unityAdsWebViewNetwork,
                               downloader: serviceProvider.webViewDownloader)
    }

    @objc
    var nativeNetworkLayer: NetworkLayerObjCBridge {
        NetworkLayerObjCBridge(network: serviceProvider.unityAdsNativeNetwork,
                               downloader: serviceProvider.webViewDownloader)
    }

    @objc
    var nativeMetricsNetworkLayer: NetworkLayerObjCBridge {
        NetworkLayerObjCBridge(network: serviceProvider.unityAdsMetricsNativeNetwork,
                               downloader: serviceProvider.webViewDownloader)
    }

    @objc
    func sdkInitializerWithFactory(_ factory: USRVInitializeStateFactory) -> SDKInitializerOBJBridge {
        serviceProvider.legacyStateFactory = factory
        return .init(sdkInitializer: serviceProvider.sdkInitializer)
    }

    @objc
    var configStorage: SDKConfigurationStorageObjcBridge {
        .init(configProvider: serviceProvider.sdkStateStorage,
              logger: serviceProvider.logger)
    }

    @objc
    init(_ delegate: ServiceProviderObjCBridgeDelegate?) {
        super.init()
        self.delegate = delegate
        subscribeDelegate()
    }

    @objc
    func saveSDKConfig(from dictionary: [String: Any]) {
        configStorage.saveSDKConfig(from: dictionary)
    }

    @objc
    func setDebugMode(_ debugMode: Bool) {
        serviceProvider.logLevel = debugMode ? .trace : .info
    }

    @objc
    func getToken(_ completion: Closure<[String: Any]>) {
        do {
            try serviceProvider.headerBiddingTokenReader.getToken({ token in
                let tokenDict = (try? token.convertIntoDictionary()) ?? [:]
                completion(tokenDict)
            })
        } catch {
            completion([:])
        }
    }
}

extension ServiceProviderObjCBridge {
    @objc var currentState: String {
        switch serviceProvider.sdkStateStorage.currentState {
        case .notInitialized:
            return "0"
        case .inProcess:
            return "1"
        case .failed:
            return "3"
        case .initialized:
            return "2"
        }
    }
}

extension ServiceProviderObjCBridge {
    @objc var gameSessionId: String {
        "\(serviceProvider.sessionInfoStorage.gameSessionID)"
    }

    @objc var sessionId: String {
        serviceProvider.sessionInfoStorage.sessionID
    }
}

private extension ServiceProviderObjCBridge {

    func subscribeDelegate() {
        serviceProvider.setLegacyInfoClosure({ [weak delegate] in
            return delegate?.getDeviceInfo(extended: $0) ?? [:]
        })

        serviceProvider.setLegacyJSONSaverClosure { [weak delegate] in
            delegate?.setValueToJSONStorage($0.1, for: $0.0)
        }

        serviceProvider.setLegacyJSONReaderClosure { [weak delegate] in
            return delegate?.getValueFromJSONStorage(for: $0)
        }

        serviceProvider.jsonStorageObjCBridge.jsonStorageReaderContentClosure = { [weak delegate] in
            delegate?.storageContent() ?? [:]
        }

        serviceProvider.setLegacyJSONKeyDeleteClosure { [weak delegate] in
            delegate?.deleteKeyFromJSONStorage(for: $0)
        }

        serviceProvider.subscribeToPrivacyComplete { [weak delegate] privacyResponse in
            delegate?.didReceivePrivacy(privacyResponse)
        }

        serviceProvider.subscribeToConfigAndInitComplete { [weak delegate] config in
            delegate?.didCompleteInit(config)
        }

    }
}
