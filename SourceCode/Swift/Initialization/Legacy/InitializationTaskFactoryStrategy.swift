import Foundation

final class InitializationTaskFactoryStrategy: TaskFactory {
    typealias SettingsProvider =  InitializationTaskFactoryBase.SettingsProvider
    private let factoryBase: InitializationTaskFactoryBase

    init(downloaderBuilder: WebViewDownloadBuilder,
         metricSenderProvider: MetricsSenderProvider & UnityAdsNetworkSenderProvider,
         sdkStateStorage: SDKStateStorage,
         performanceMeasurer: PerformanceMeasurer<String>,
         stateFactoryObjc: USRVInitializeStateFactory = .init(),
         settingsProvider: SettingsProvider) {

        self.factoryBase = .init(downloaderBuilder: downloaderBuilder,
                                 metricSenderProvider: metricSenderProvider,
                                 sdkStateStorage: sdkStateStorage,
                                 performanceMeasurer: performanceMeasurer,
                                 stateFactoryObjc: stateFactoryObjc,
                                 settingsProvider: settingsProvider)
    }

    func task(of type: InitTaskCategory) -> Task {
        switch type {
        case .sync(let state):
            return factoryBase.task(of: state)
        case .async(let sequence):
            return AsyncTaskRunner(factory: factoryBase, sequence: sequence)
        }
    }
}
