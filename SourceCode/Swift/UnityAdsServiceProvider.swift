import Foundation
// swiftlint:disable type_body_length
final class UnityAdsServiceProvider {
    typealias TimeInfoReader = BootTimeReader & TimeZoneReader & TimeReader
    var sdkStateStorage: SDKStateStorage
    var skdSettingsStorage: SDKSettingsStorage
    var allowedNetworkCodes = Array(200...299)
    var legacyStateFactory = USRVInitializeStateFactory()
    var sessionInfoStorage: SessionInfoReader

    let performanceMeasurer: PerformanceMeasurer<String> // probably should use a struct to represent System?

    var logLevel: LogLevel {
        get { skdSettingsStorage.currentLevel }
        set { skdSettingsStorage.currentLevel = newValue }
    }
    var logger: Logger

    private let networkServicesFactory: UnityAdsNetworkServicesFactory
    private let eventsNetworkServicesFactory: UnityAdsEventsNetworkServicesFactory
    private let syncQueue: DispatchQueue = .init(label: "Sync.queue")
    let jsonStorageObjCBridge = JSONStorageBridge()
    let timeInfoReader: TimeInfoReader
    let trackingStatusReader: TrackingStatusReader = TrackingStatusReaderBase()
    let headerBiddingTokenReader: HeaderBiddingTokenReader
    private let deviceInfoReaderBuilder: DeviceInfoBodyReaderBuilder
    init(skdSettingsStorage: SDKSettingsStorage = .init(),
         timeReader: TimeInfoReader = TimeReaderBase(),
         telephonyProvider: TelephonyInfoProvider & CountryCodeProvider = TelephonyNetworkStatusProvider()) {
        self.skdSettingsStorage = skdSettingsStorage
        self.timeInfoReader = timeReader
        let loggerStrategy = LoggerStrategy(settingsReader: skdSettingsStorage)
        logger = LoggerWithGate(loggerLevelReader: skdSettingsStorage,
                                original: loggerStrategy)

        let fileStorage = SDKConfigurationFileStorage(filePaths: skdSettingsStorage.filePaths,
                                                      logger: logger)
        let sdkConfigurationStorage = SDKConfigurationInMemoryStorage(fileStorage: fileStorage)
        sdkStateStorage = SDKStateStorage(configProvider: sdkConfigurationStorage)

        sessionInfoStorage = SessionInfoStorage(settings: .defaultSettings(privateStorage: jsonStorageObjCBridge))

        performanceMeasurer = .init(timeReader: timeInfoReader)

        let eventsServicesConfig = UnityAdsEventsNetworkServicesFactory.Config(configProvider: sdkStateStorage,
                                                                               metricsDataReader: sdkStateStorage,
                                                                               retriesReader: sdkStateStorage,
                                                                               logger: logger,
                                                                               settingsReader: skdSettingsStorage,
                                                                               sessionInfoReader: sessionInfoStorage)

        eventsNetworkServicesFactory = UnityAdsEventsNetworkServicesFactory(config: eventsServicesConfig)
        let builderConfig = DeviceInfoBodyReaderBuilder.Config(sessionInfoStorage: sessionInfoStorage,
                                                               trackingStatusReader: trackingStatusReader,
                                                               gameSettingsReader: skdSettingsStorage,
                                                               sdkStateStorage: sdkStateStorage,
                                                               persistenceStorage: jsonStorageObjCBridge,
                                                               logger: logger,
                                                               timeReader: timeReader,
                                                               telephonyInfoProvider: telephonyProvider,
                                                               performanceMeasurer: performanceMeasurer,
                                                               metricsSender: eventsNetworkServicesFactory.metricsSender)
        deviceInfoReaderBuilder = DeviceInfoBodyReaderBuilder(baseConfig: builderConfig)

        networkServicesFactory = .init(settingsProvider: skdSettingsStorage,
                                       configurationProvider: sdkStateStorage,
                                       deviceInfoReaderProvider: deviceInfoReaderBuilder,
                                       performanceMeasurer: performanceMeasurer,
                                       logger: logger,
                                       metricSenderProvider: eventsNetworkServicesFactory)

        let hbTokenConfig = HeaderBiddingTokenReaderBase.Config(
            deviceInfoReader: deviceInfoReaderBuilder.deviceInfoBodyReader,
            compressor: Base64GzipCompressor(dataCompressor: GZipCompressor()),
            customPrefix: "1:",
            uniqueIdGenerator: IdentifiersGeneratorBase(),
            experiments: sdkConfigurationStorage)
        headerBiddingTokenReader = HeaderBiddingTokenReaderBase(hbTokenConfig)
    }

    private var _sdkInitializer: SDKInitializer?

    var sdkInitializer: SDKInitializer {
        syncQueue.sync { getOrCreateInitializer() }
    }
}

extension UnityAdsServiceProvider {
    func updateConfiguration(_ config: UnityAdsConfig) {
        sdkStateStorage.config = config
    }

    func setLegacyInfoClosure(_ closure: ClosureWithReturn<Bool, [String: Any]>?) {
        deviceInfoReaderBuilder.setLegacyInfoGetter(closure)
    }

    func setLegacyJSONReaderClosure(_ closure: ClosureWithReturn<String, Any?>?) {
        jsonStorageObjCBridge.jsonStorageReaderClosure = closure
    }

    func setLegacyJSONSaverClosure(_ closure: Closure<(String, Any?)>?) {
        jsonStorageObjCBridge.jsonStorageSaverClosure = closure
    }

    func setLegacyJSONKeyDeleteClosure(_ closure: Closure<String>?) {
        jsonStorageObjCBridge.jsonStorageDeleteClosure = closure
    }
}

private extension UnityAdsServiceProvider {
    func getOrCreateInitializer() -> SDKInitializer {
        guard let initializer = _sdkInitializer else {
            let new = SDKInitializerBase(task: initTaskRunner,
                                         stateStorage: sdkStateStorage,
                                         settingsStorage: skdSettingsStorage)
            _sdkInitializer = new
            return new
        }
        return initializer
    }
}

// subscribe for updates. Used by objc layer
extension UnityAdsServiceProvider {

    func subscribeToConfigAndInitComplete(_ closure: @escaping Closure<[String: Any]>) {
        sdkStateStorage.configProvider.subscribe { config in
            closure( (try? config.legacy.convertIntoDictionary()) ?? [:] )
        }

        sdkStateStorage.subscribe {[weak sdkStateStorage] in
            guard let config = try? sdkStateStorage?.config.legacy.convertIntoDictionary() else { return }
            closure(config)
        }
    }

    func subscribeToPrivacyComplete(_ closure: @escaping Closure<[String: Any]>) {
        sdkStateStorage.subscribeToPrivacy { result in
            result.do({ response in
                guard let privacyResponse = try? response.asErasedDictionary else { return }
                closure(privacyResponse)
            })
        }
    }
}

// Network layers
extension UnityAdsServiceProvider {

    var unityAdsWebViewNetwork: UnityAdsWebViewNetwork {
        networkServicesFactory.unityAdsWebViewNetwork
    }

    var webViewDownloader: WebViewDownloader {
        networkServicesFactory.webViewDownLoader
    }

    var unityAdsNativeNetwork: UnityAdsWebViewNetwork {
        networkServicesFactory.unityAdsNativeNetwork
    }

    var unityAdsMetricsNativeNetwork: UnityAdsWebViewNetwork {
        eventsNetworkServicesFactory.unityAdsMetricsNativeNetwork
    }
}

extension UnityAdsServiceProvider {
    private var initTaskRunner: Task {
        TaskPerformanceDecorator(original: mainTask,
                                 metricSender: eventsNetworkServicesFactory.metricsSender,
                                 performanceMeasurer: performanceMeasurer)
    }

    private var mainTask: PerformanceMeasurableTask {
        StartInitTask(factory: initTaskFactory,
                      sequence: sequence,
                      timeReader: timeInfoReader,
                      appStartTimeSaver: sdkStateStorage,
                      logger: logger,
                      settingProvider: skdSettingsStorage,
                      sessionInfoReader: sessionInfoStorage)
    }

    private var sequence: [InitTaskCategory] {
        // this makes load config task irrelevant, because we already triggering loading config.
        // There is no other way to prevent it since we need it to define what to do next
        // in future, when we move to the new init flow implementation, we wont need to have different flow
        // unless we need to change starting point of the init flow sequence.
        // Experiments reader can help if it doesn't touch the initial state that is LoadLocalConfig

        return InitializationSequence(experimentsReader: sdkStateStorage).sequence

    }

    var initTaskFactory: InitializationTaskFactoryStrategy {
        .init(downloaderBuilder: networkServicesFactory.webViewDownloaderBuilder,
              metricSenderProvider: eventsNetworkServicesFactory,
              networkSenderProvider: networkServicesFactory,
              sdkStateStorage: sdkStateStorage,
              performanceMeasurer: performanceMeasurer,
              stateFactoryObjc: legacyStateFactory,
              settingsProvider: skdSettingsStorage,
              keyValueStorage: jsonStorageObjCBridge,
              cleanupKeys: [JSONStorageKeys.GameSessionID],
              deviceInfoReader: deviceInfoReaderBuilder.deviceInfoBodyReader)
    }

}

extension SessionInfoStorage.Settings {
    static func defaultSettings(privateStorage: KeyValueStorage,
                                idGenerator: IdentifiersGenerator = IdentifiersGeneratorBase()) -> Self {
        .init(privateStorage: privateStorage,
              gameSessionIDKey: JSONStorageKeys.GameSessionID,
              sessionIDKey: JSONStorageKeys.SessionID,
              userIDKey: JSONStorageKeys.UserID,
              idfiIDKey: JSONStorageKeys.IDFI,
              auIDKey: JSONStorageKeys.AUID,
              userNonBehavioralFlagKey: JSONStorageKeys.UserNonBehavioralValue,
              idGenerator: idGenerator)
    }
}
