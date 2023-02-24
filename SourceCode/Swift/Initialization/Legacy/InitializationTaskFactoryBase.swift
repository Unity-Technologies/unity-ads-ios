import Foundation

final class InitializationTaskFactoryBase: TaskFactory {
    typealias SettingsProvider =  LoggerSettingsReader
    private let downloaderBuilder: WebViewDownloadBuilder
    private let networkSenderProvider: MetricsSenderProvider & UnityAdsNetworkSenderProvider
    private let objcFactory: USRVInitializeStateFactory
    private let performanceMeasurer: PerformanceMeasurer<String>
    private let sdkStateStorage: SDKStateStorage
    private let settingsProvider: SettingsProvider
    private var networkConfig: UnityAdsConfig.Network { sdkStateStorage.networkConfig }

    init(downloaderBuilder: WebViewDownloadBuilder,
         metricSenderProvider: MetricsSenderProvider & UnityAdsNetworkSenderProvider,
         sdkStateStorage: SDKStateStorage,
         performanceMeasurer: PerformanceMeasurer<String>,
         stateFactoryObjc: USRVInitializeStateFactory = .init(),
         settingsProvider: SettingsProvider) {
        self.downloaderBuilder = downloaderBuilder
        self.objcFactory = stateFactoryObjc
        self.networkSenderProvider = metricSenderProvider
        self.performanceMeasurer = performanceMeasurer
        self.sdkStateStorage = sdkStateStorage
        self.settingsProvider = settingsProvider
    }

    func task(of type: InitTaskState) -> Task {
       decorateTaskIntoPerformanceMetrics(createTask(of: type), type: type)
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
                                                                          collectCompressionMetrics: true), retriesInfoWriter: sdkStateStorage)
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

    private func createTask(of type: InitTaskState) -> PerformanceMeasurableTask {
        switch type {
        case .webViewDownload:
            return useNewTasksFlow ? WebViewDownloadTask(downloader: downloaderBuilder.webViewDownloader,
                                                         experimentsReader: sdkStateStorage) : taskForObjcType(type)
        case .privacyFetch:
            return useNewTasksFlow ? privacyTask : taskForObjcType(type)
        case .configFetch:
            return useNewTasksFlow ? configTask : taskForObjcType(type)
        case .loadLocalConfig:
            return useNewTasksFlow ? loadLocalConfigTask: taskForObjcType(type)
        case .reset:
            let legacy = taskForObjcType(type)
            return useNewTasksFlow ? PreviousSessionCleanupTask(loggerSettingsReader: settingsProvider,
                                                                legacyTask: legacy) : legacy
        default:
            return taskForObjcType(type)
        }
    }

    private func taskForObjcType(_ type: InitTaskState) -> PerformanceMeasurableTask {
        InitializationStateTaskBridge(objcState: objcFactory.state(for: type.legacyType),
                                      resultMetrics: type.metricsType,
                                      onComplete: { [weak self] in
            self?.setRetriesCount($0, for: type)
        })
    }

    private func decorateTaskIntoPerformanceMetrics(_ task: PerformanceMeasurableTask,
                                                    type: InitTaskState) -> Task {
        TaskPerformanceDecorator(original: task,
                                 metricSender: metricSender,
                                 performanceMeasurer: performanceMeasurer)
    }

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

    private func setRetriesCount(_ obj: USRVInitializeTask, for type: InitTaskState) {
        if type == .configFetch {
            sdkStateStorage.set(retried: obj.retryCount(), task: .config)
        } else if type == .webViewDownload {
            sdkStateStorage.set(retried: obj.retryCount(), task: .webview)
        }
    }
}

extension InitializationTaskFactoryBase {
    var useNewTasksFlow: Bool {
         isTaskEnabled || isParallelEnabled

    }
    private var isTaskEnabled: Bool {
        sdkStateStorage.experiments?.isUseNewTasksEnabled.value ?? false
    }
    private var isParallelEnabled: Bool {
        sdkStateStorage.experiments?.isParallelExecutionEnabled.value ?? false
    }

}
