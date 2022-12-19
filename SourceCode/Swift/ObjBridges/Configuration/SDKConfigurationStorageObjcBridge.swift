import Foundation

@objc
public final class SDKConfigurationStorageObjcBridge: NSObject {

    private var configProvider: UnityAdsConfigurationProvider
    let logger: Logger
    init(configProvider: UnityAdsConfigurationProvider, logger: Logger) {
        self.configProvider = configProvider
        self.logger = logger
        super.init()
    }

    @objc
    public var configDictionary: [String: Any] {
        (try? configProvider.config.legacy.asErasedDictionary) ?? [:]
    }

    @objc
    public func saveSDKConfig(from dictionary: [String: Any]) {

        do {
            let legacy = try LegacySDKConfig(dictionary: dictionary)
            configProvider.config = .init(from: legacy)
        } catch {
            logger.trace(system: "\(self)", message: error.localizedDescription)
        }

    }

}
