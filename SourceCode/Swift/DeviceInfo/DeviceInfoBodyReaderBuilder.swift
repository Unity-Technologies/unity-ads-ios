import Foundation
import AVFoundation
import UIKit

extension WebUserAgentReaderBase {
    static var unityAdsAgent: WebUserAgentReader {
        WebUserAgentReaderBase(lastKnownOSKey: Constants.UserDefaultsKeys.LastKnownSystemVersion,
                                                     userAgentValueKey: Constants.UserDefaultsKeys.LastKnownUserAgentKey)
    }
}

final class DeviceInfoBodyReaderBuilder: DeviceInfoBodyReaderProvider {

    private let baseConfig: Config
    private(set) var getLegacyInfo: ClosureWithReturn<Bool, [String: Any]>?
    private let deviceInfoReader: DeviceInfoReader
    init(baseConfig: Config) {
        self.baseConfig = baseConfig

        let deviceInfoConfig = DeviceInfoReaderBase.Config(timeReader: baseConfig.timeReader,
                                                           logger: baseConfig.logger,
                                                           userAgentReader: WebUserAgentReaderBase.unityAdsAgent,
                                                           sessionInfoProvider: baseConfig.sessionInfoStorage,
                                                           gameSettingsReader: baseConfig.gameSettingsReader,
                                                           appStartTimeProvider: baseConfig.sdkStateStorage,
                                                           telephonyInfoProvider: baseConfig.telephonyInfoProvider)
        deviceInfoReader = DeviceInfoReaderBase(config: deviceInfoConfig)
    }

    var deviceInfoBodyReader: DeviceInfoBodyStrategy {
        self.reader(using: baseConfig)
    }

    func setLegacyInfoGetter(_ closure: ClosureWithReturn<Bool, [String: Any]>?) {
        getLegacyInfo = closure
    }

}

extension DeviceInfoBodyReaderBuilder {
    private func reader(using config: Config) -> DeviceInfoBodyStrategy {
        let minStorageReader = JSONStorageContentNormalizer.minStorageContentReader(with: config.persistenceStorage)
        let extendedStorageReader = JSONStorageContentNormalizer.extendedStorageContentReader(with: config.persistenceStorage)

        let strategyConfig = DeviceInfoBodyStrategyBase.Config(sessionInfoStorage: config.sessionInfoStorage,
                                                               trackingStatusReader: config.trackingStatusReader,
                                                               gameIdProvider: config.gameSettingsReader,
                                                               deviceInfoReader: deviceInfoReader,
                                                               privacyReader: config.sdkStateStorage,
                                                               piiDataProvider: config.piiDataProvider,
                                                               minStorageContentReader: minStorageReader,
                                                               extendedStorageContentReader: extendedStorageReader)

        var base: DeviceInfoBodyStrategy = DeviceInfoBodyStrategyBase(config: strategyConfig)

        base = DeviceInfoBodyReaderWithMetrics(original: base,
                                               measurer: baseConfig.performanceMeasurer,
                                               metricsSender: baseConfig.metricsSender)
        let decoratorConfig = DeviceInfoObjBridgeDecorator.Config(logger: config.logger,
                                                                  experimentsReader: config.sdkStateStorage,
                                                                  original: base,
                                                                  getLegacyInfo: getLegacyInfo)
        return DeviceInfoObjBridgeDecorator(config: decoratorConfig)
    }
}

extension DeviceInfoBodyReaderBuilder {
    typealias TimeInfoReader = BootTimeReader & TimeZoneReader & TimeReader
    struct Config {
        let sessionInfoStorage: SessionInfoReader
        let trackingStatusReader: TrackingStatusReader
        let gameSettingsReader: SDKGameSettingsProvider
        let sdkStateStorage: PrivacyStateReader & ExperimentsReader & AppStartTimeProvider
        var piiDataProvider: UIDevicePIIDataProvider = UIDevice.current
        let persistenceStorage: JSONStorageBridge
        let logger: Logger
        let timeReader: TimeInfoReader
        let telephonyInfoProvider: TelephonyInfoProvider & CountryCodeProvider
        let performanceMeasurer: PerformanceMeasurer<String>
        let metricsSender: MetricSender
    }

}
