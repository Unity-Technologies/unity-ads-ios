import Foundation

final class InitializationTaskFactoryStrategy: TaskFactory {
    private let factoryBase: InitializationTaskFactoryBase

    init(downloaderBuilder: WebViewDownloadBuilder,
         metricSenderProvider: MetricsSenderProvider & UnityAdsNetworkSenderProvider,
         sdkStateStorage: SDKStateStorage,
         performanceMeasurer: PerformanceMeasurer<String>,
         stateFactoryObjc: USRVInitializeStateFactory = .init(),
         retriesInfoWriter: RetriesInfoWriter) {

        self.factoryBase = .init(downloaderBuilder: downloaderBuilder,
                                 metricSenderProvider: metricSenderProvider,
                                 sdkStateStorage: sdkStateStorage,
                                 performanceMeasurer: performanceMeasurer,
                                 stateFactoryObjc: stateFactoryObjc,
                                 retriesInfoWriter: retriesInfoWriter)
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
