import Foundation

final class ConfigFetchTask: PerformanceMeasurableTask {
    var startEventName: String?
    var resultMetrics: ResultMetrics.Type { Constants.Metrics.Task.ConfigFetch.self }
    let id: UUID = .init()

    private let asyncReader: ConfigAsyncReader
    private var storage: UnityAdsConfigurationProvider
    init(asyncReader: ConfigAsyncReader, storage: UnityAdsConfigurationProvider) {
        self.asyncReader = asyncReader
        self.storage = storage
    }

    func start(completion: @escaping ResultClosure<Void>) {
        asyncReader.getConfigData {[self] result in
            result.do(self.saveConfig)
                  .map({ _ in })
                  .sink(completion)
        }
    }

    private func saveConfig(_ config: UnityAdsConfig) {
        storage.config = config
    }
}
