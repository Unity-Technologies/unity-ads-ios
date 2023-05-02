import Foundation

final class InitializationTaskFactoryStrategy: TaskFactory {
    typealias SettingsProvider =  InitializationTaskFactoryBase.SettingsProvider
    private let factoryBase: InitializationTaskFactoryBase

    init(downloaderBuilder: WebViewDownloadBuilder,
         metricSenderProvider: MetricsSenderProvider,
         networkSenderProvider: UnityAdsNetworkSenderProvider,
         sdkStateStorage: SDKStateStorage,
         performanceMeasurer: PerformanceMeasurer<String>,
         stateFactoryObjc: USRVInitializeStateFactory = .init(),
         settingsProvider: SettingsProvider,
         keyValueStorage: KeyValueStorage,
         cleanupKeys: [String],
         deviceInfoReader: DeviceInfoBodyStrategy) {

        self.factoryBase = .init(downloaderBuilder: downloaderBuilder,
                                 metricSenderProvider: metricSenderProvider,
                                 networkSenderProvider: networkSenderProvider,
                                 sdkStateStorage: sdkStateStorage,
                                 performanceMeasurer: performanceMeasurer,
                                 stateFactoryObjc: stateFactoryObjc,
                                 settingsProvider: settingsProvider,
                                 keyValueStorage: keyValueStorage,
                                 cleanupKeys: cleanupKeys,
                                 deviceInfoReader: deviceInfoReader)
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
