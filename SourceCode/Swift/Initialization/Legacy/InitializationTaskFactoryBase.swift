import Foundation

final class InitializationTaskFactoryBase: TaskFactory {
    private let downloaderBuilder: WebViewDownloadBuilder
    private let networkSenderProvider: MetricsSenderProvider & UnityAdsNetworkSenderProvider
    private let objcFactory: USRVInitializeStateFactory
    private let performanceMeasurer: PerformanceMeasurer<String>
    private let sdkStateStorage: SDKStateStorage
    private let retriesInfoWriter: RetriesInfoWriter
    private var networkConfig: UnityAdsConfig.Network {
        sdkStateStorage.networkConfig
    }

    init(downloaderBuilder: WebViewDownloadBuilder,
         metricSenderProvider: MetricsSenderProvider & UnityAdsNetworkSenderProvider,
         sdkStateStorage: SDKStateStorage,
         performanceMeasurer: PerformanceMeasurer<String>,
         stateFactoryObjc: USRVInitializeStateFactory = .init(),
         retriesInfoWriter: RetriesInfoWriter) {
        self.downloaderBuilder = downloaderBuilder
        self.objcFactory = stateFactoryObjc
        self.networkSenderProvider = metricSenderProvider
        self.performanceMeasurer = performanceMeasurer
        self.sdkStateStorage = sdkStateStorage
        self.retriesInfoWriter = retriesInfoWriter
    }

    func task(of type: InitTaskState) -> Task {
       decorateTaskIntoPerformanceMetrics(createTask(of: type), type: type)
    }

    private func createTask(of type: InitTaskState) -> PerformanceMeasurableTask {
        switch type {
        case .webViewDownload:
            return useNewTasksFlow ? WebViewDownloadTask(downloader: downloaderBuilder.webViewDownloader) : taskForObjcType(type)
        case .privacyFetch:
            return useNewTasksFlow ? privacyTask : taskForObjcType(type)
        case .configFetch:
            return useNewTasksFlow ? configTask : taskForObjcType(type)
        case .loadLocalConfig:
            return useNewTasksFlow ? loadLocalConfigTask: taskForObjcType(type)
        default:
            return taskForObjcType(type)
        }
    }

    private func taskForObjcType(_ type: InitTaskState) -> PerformanceMeasurableTask {
        InitializationStateTaskBridge(objcState: objcFactory.state(for: type.legacyType), resultMetrics: type.metricsType)
    }

    private func decorateTaskIntoPerformanceMetrics(_ task: PerformanceMeasurableTask,
                                                    type: InitTaskState) -> Task {
        TaskPerformanceDecorator(original: task,
                                 metricSender: metricSender,
                                 performanceMeasurer: performanceMeasurer)
    }

}

extension InitializationTaskFactoryBase {
    private var loadLocalConfigTask: PerformanceMeasurableTask {
        LocalConfigFetchTask(loader: sdkStateStorage)
    }
    private var configTask: PerformanceMeasurableTask {
        ConfigFetchTask(asyncReader: configFetcher, storage: sdkStateStorage)
    }

    private var configFetcher: ConfigAsyncReader {
        baseConfigFetcher.withDefaultMetrics(measurer: performanceMeasurer, metricsSender: metricSender)
    }

    private var baseConfigFetcher: ConfigAsyncReader {
        // probably move logic to a service provider or network factory so we have decision in one place
        // in future we might want it to be controlled from outside based on the usecase
        ConfigAsyncReaderBase(network: networkSenderProvider.networkSender(includeRetryLogic: true,
                                                                          collectCompressionMetrics: true), retriesInfoWriter: retriesInfoWriter)
    }
}

extension InitializationTaskFactoryBase {
    var metricSender: MetricSender {
        networkSenderProvider.metricsSender
    }

    var requestRetryConfig: RetriableOperationConfig {
        .init(with: networkConfig.request.retry)
    }
}

// Privacy
extension InitializationTaskFactoryBase {

    private var privacyTask: PerformanceMeasurableTask {
        PrivacyFetchTask(asyncReader: privacyFetcher, storage: sdkStateStorage)
    }

    private var privacyFetcher: PrivacyAsyncReader {
        PrivacyAsyncReaderWithMetrics(original: basePrivacyFetcher,
                                      measurer: performanceMeasurer,
                                      metricsSender: metricSender)

    }

    private var basePrivacyFetcher: PrivacyAsyncReaderBase {
        // probably move logic to a service provider or network factory so we have decision in one place
        // in future we might want it to be controlled from outside based on the usecase
        PrivacyAsyncReaderBase(network: networkSenderProvider.networkSender(includeRetryLogic: false, collectCompressionMetrics: false))
    }

}

extension InitializationTaskFactoryBase {
    var useNewTasksFlow: Bool {
         isTaskEnabled || isParallelEnabled

    }
    private var isTaskEnabled: Bool {
        sdkStateStorage.config.experiments?.isUseNewTasksEnabled.value ?? false
    }
    private var isParallelEnabled: Bool {
        sdkStateStorage.config.experiments?.isParallelExecutionEnabled.value ?? false
    }

}
