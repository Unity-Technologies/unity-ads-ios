import Foundation

final class LocalConfigFetchTask: PerformanceMeasurableTask {
    var startEventName: String?
    var resultMetrics: ResultMetrics.Type { Constants.Metrics.Task.LoadLocalConfig.self }
    let id: UUID = .init()
    private let loader: UnityAdsLocalConfigurationLoader
    init(loader: UnityAdsLocalConfigurationLoader) {
        self.loader = loader
    }

    func start(completion: @escaping ResultClosure<Void>) {
        loader.loadLocalConfig()
        completion(VoidSuccess)
    }
}
