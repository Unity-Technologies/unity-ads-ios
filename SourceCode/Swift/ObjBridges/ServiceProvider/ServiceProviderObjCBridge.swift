import Foundation

@objc
protocol ServiceProviderObjCBridgeDelegate: AnyObject {
    func getDeviceInfo(extended: Bool) -> [String: Any]
    func didCompleteInit(_ config: [String: Any])
    func didReceivePrivacy(_ privacy: [String: Any])
}

@objc
final class ServiceProviderObjCBridge: NSObject {

    private(set) weak var delegate: ServiceProviderObjCBridgeDelegate?

    var serviceProvider = UnityAdsServiceProvider() {
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

    private func subscribeDelegate() {
        serviceProvider.setLegacyInfoClosure({ [weak delegate] in
            return delegate?.getDeviceInfo(extended: $0) ?? [:]
        })

        serviceProvider.subscribeToPrivacyComplete { [weak delegate] privacyResponse in
            delegate?.didReceivePrivacy(privacyResponse)
        }

        serviceProvider.subscribeToConfigAndInitComplete { [weak delegate] config in
            delegate?.didCompleteInit(config)
        }
    }

}
