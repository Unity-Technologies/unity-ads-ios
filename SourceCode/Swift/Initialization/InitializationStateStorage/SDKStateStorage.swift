import Foundation

protocol InitializationStateSubject {
    func subscribe(_ block: @escaping ResultClosure<Void>)
}

protocol AppStartTimeSaver {
    func save(startTime: TimeInterval)
}
final class SDKStateStorage: GenericMediator<UResult<Void>>,
                             InitializationStateSubject,
                             MetricsSenderBatchConditionSubject,
                             UnityAdsConfigurationProvider,
                             UnityAdsLocalConfigurationLoader,
                             RetriesInfoStorage {
    let retriesInfoStorage: RetriesInfoWriter & RetriesInfoReader = RetriesInfoStorageBase()

    typealias ConfigProvider = UnityAdsConfigurationProvider &
                               UnityAdsLocalConfigurationLoader &
                               UnityAdsConfigSubject &
                               ExperimentsReader

    @Atomic private var startTimeStamp: TimeInterval = 0

    @Atomic private var initializeState: SDKInitializerBase.State = .notInitialized

    private let privacyStorage = PrivacyStateStorage()

    private(set) var configProvider: ConfigProvider

    init(configProvider: ConfigProvider) {
        self.configProvider = configProvider
    }

    var webViewConfig: UnityAdsConfig.Network.WebView {
        guard !privacyStorage.$privacyResponse.load().webViewConfig.url.isEmpty else {
            return config.network.webView
        }
        return  privacyStorage.$privacyResponse.load().webViewConfig
    }

    var config: UnityAdsConfig {
        get { configProvider.config }
        set { configProvider.config = newValue }
    }

    var currentState: SDKInitializerBase.State {
        get { _initializeState.load() }
        set {
            _initializeState.mutate({ $0 = newValue })
            notifyStateChange()
        }
    }

    // Metric Condition subscribes to be able to release batch on failure or success.
    func subscribe(_ block: @escaping VoidClosure) {
        subscribe { (_: UResult<Void>) in
            block()
        }
    }

    func loadLocalConfig() {
        configProvider.loadLocalConfig()
    }

    private func notifyStateChange() {
        switch currentState {

        case let .failed(error):
            notifyObservers(with: .failure(error))
        case .initialized:
            notifyObservers(with: VoidSuccess)
        default: return
        }
    }
}

extension SDKStateStorage: PrivacyStateReader, PrivacyResponseSaver {
    var shouldSendNonBehavioural: Bool { privacyStorage.shouldSendNonBehavioural }

    var privacyState: PrivacyState { privacyStorage.privacyState }

    func save(response: PrivacyResponse) {
        privacyStorage.save(response: response)
    }

    func subscribeToPrivacy(_ block: @escaping Closure<UResult<PrivacyResponse>>) {
        privacyStorage.subscribe(block)
    }
}

extension SDKStateStorage: ExperimentsReader, SessionTokenReader {
    var experiments: ConfigExperiments? {
        configProvider.experiments
    }

    var sessionToken: String {
        config.legacy.sTkn
    }
}

extension SDKStateStorage {
    func retryInfo() -> [String: String] {
        retriesInfoStorage.retryInfo()
    }

    func set(retried: Int, task: RetriableTask) {
        retriesInfoStorage.set(retried: retried, task: task)
    }
}

extension SDKStateStorage: AppStartTimeSaver, AppStartTimeProvider {

    var appStartTime: TimeInterval {
        _startTimeStamp.load()
    }

    func save(startTime: TimeInterval) {
        _startTimeStamp.mutate({ $0 = startTime })
    }
}
