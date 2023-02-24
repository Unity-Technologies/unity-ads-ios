import Foundation

protocol InitializationStateSubject {
    func subscribe(_ block: @escaping ResultClosure<Void>)
}

final class SDKStateStorage: GenericMediator<UResult<Void>>,
                             InitializationStateSubject,
                             MetricsSenderBatchConditionSubject,
                             UnityAdsConfigurationProvider,
                             UnityAdsLocalConfigurationLoader,
                             RetriesInfoStorage {

    typealias ConfigProvider = UnityAdsConfigurationProvider &
                               UnityAdsLocalConfigurationLoader &
                               UnityAdsConfigSubject &
                               ExperimentsReader

    @Atomic var currentState: SDKInitializerBase.State = .notInitialized {
        didSet {
            notifyStateChange()
        }
    }

    var webViewConfig: UnityAdsConfig.Network.WebView {
        guard !privacyStorage.privacyResponse.webViewConfig.url.isEmpty else {
            return config.network.webView
        }
        return  privacyStorage.privacyResponse.webViewConfig
    }

    var config: UnityAdsConfig {
        get { configProvider.config }
        set { configProvider.config = newValue }
    }

    private let privacyStorage = PrivacyStateStorage()

    private(set) var configProvider: ConfigProvider
    let retriesInfoStorage: RetriesInfoWriter & RetriesInfoReader = RetriesInfoStorageBase()

    init(configProvider: ConfigProvider) {
        self.configProvider = configProvider
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

final class PrivacyStateStorage: GenericMediator<UResult<PrivacyResponse>>,
                                 PrivacyStateReader,
                                 PrivacyResponseSaver {
    @Atomic var privacyResponse: PrivacyResponse = .empty

    var privacyState: PrivacyState { privacyResponse.state }

    func save(response: PrivacyResponse) {
        privacyResponse = response
        notifyObservers(with: .success(privacyResponse))
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
