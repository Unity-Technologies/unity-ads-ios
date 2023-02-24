import Foundation

class UnityAdsServiceProvider {

    var sdkStateStorage: SDKStateStorage
    var skdSettingsStorage: SDKSettingsStorage
    var deviceInfoReader: DeviceInfoReader & LegacyDeviceInfoReader
    var allowedNetworkCodes = Array(200...299)
    var legacyStateFactory = USRVInitializeStateFactory()

    let performanceMeasurer: PerformanceMeasurer<String> // probably should use a struct to represent System?

    var logLevel: LogLevel {
        get { skdSettingsStorage.currentLevel }
        set { skdSettingsStorage.currentLevel = newValue }
    }
    var logger: Logger

    private let networkServicesFactory: UnityAdsNetworkServicesFactory
    private let timeReader: TimeReader
    private let syncQueue: DispatchQueue = .init(label: "Sync.queue")

    init(skdSettingsStorage: SDKSettingsStorage = .init()) {
        timeReader = TimeReaderBase()
        self.skdSettingsStorage = skdSettingsStorage

        let loggerStrategy = LoggerStrategy(settingsReader: skdSettingsStorage)
        logger = LoggerWithGate(loggerLevelReader: skdSettingsStorage,
                                original: loggerStrategy)
        deviceInfoReader = defaultDeviceInfoReader(withLogger: logger)
        let fileStorage = SDKConfigurationFileStorage(filePaths: skdSettingsStorage.filePaths, logger: logger)

        let sdkConfigurationStorage = SDKConfigurationInMemoryStorage(fileStorage: fileStorage)
        sdkStateStorage = SDKStateStorage(configProvider: sdkConfigurationStorage)

        performanceMeasurer = .init(timeReader: timeReader)
        networkServicesFactory = .init(settingsProvider: skdSettingsStorage,
                                       configurationProvider: sdkStateStorage,
                                       deviceInfoReader: deviceInfoReader,
                                       performanceMeasurer: performanceMeasurer,
                                       logger: logger)
    }

    private var _sdkInitializer: SDKInitializer?

    var sdkInitializer: SDKInitializer {
        syncQueue.sync { getOrCreateInitializer() }
    }

    func updateConfiguration(_ config: UnityAdsConfig) {
        sdkStateStorage.config = config
    }

    func setLegacyInfoClosure(_ closure: ClosureWithReturn<Bool, [String: Any]>?) {
        deviceInfoReader.setLegacyInfoGetter(closure)
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
        networkServicesFactory.unityAdsMetricsNativeNetwork
    }
}

extension UnityAdsServiceProvider {
    private var initTaskRunner: Task {
        TaskPerformanceDecorator(original: mainTask,
                                 metricSender: networkServicesFactory.metricsSender,
                                 performanceMeasurer: performanceMeasurer)
    }

    private var mainTask: PerformanceMeasurableTask {
        StartInitTask(factory: initTaskFactory, sequence: sequence)
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
              metricSenderProvider: networkServicesFactory,
              sdkStateStorage: sdkStateStorage,
              performanceMeasurer: performanceMeasurer,
              stateFactoryObjc: legacyStateFactory,
              settingsProvider: skdSettingsStorage)
    }

}

private func defaultDeviceInfoReader(withLogger logger: Logger) -> DeviceInfoReader & LegacyDeviceInfoReader {
    let webUserAgent = WebUserAgentReaderBase(lastKnownOSKey: Constants.UserDefaultsKeys.LastKnownSystemVersion,
                                              userAgentValueKey: Constants.UserDefaultsKeys.LastKnownUserAgentKey)
    return DeviceInfoReaderBase(logger: logger, userAgentReader: webUserAgent)
}
