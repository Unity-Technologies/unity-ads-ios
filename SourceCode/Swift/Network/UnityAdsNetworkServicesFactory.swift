import Foundation

protocol MetricsSenderProvider {
    var metricsSender: MetricSender { get }
}

protocol UnityAdsNetworkSenderProvider {
    func networkSender(includeRetryLogic: Bool, collectCompressionMetrics: Bool) -> UnityAdsNetworkSender
}

protocol NetworkSettingsProvider {
    var metricSessionConfiguration: URLSessionConfiguration { get }
    var mainSessionConfiguration: URLSessionConfiguration { get }
    var responseSuccessCodes: [Int] { get }
    var metricsResourceTypes: [Int] { get }
}

/**
 Factory that creates network services for swift layer as well as objc layer. Services can be used with metrics or without them.
 
 */
final class UnityAdsNetworkServicesFactory: MetricsSenderProvider {
    typealias ConfigProvider = UnityAdsConfigurationProvider &
                               MetricsSenderBatchConditionSubject &
                               ExperimentsReader &
                               SessionTokenReader
    private let configurationProvider: ConfigProvider
    private let metricsCollector: URLSessionTaskMetricCollector = URLSessionTaskMetricCollectorBase()
    private var metricSession: URLSession
    private var mainSession: URLSession
    private let allowedCodes: [Int]
    private let filePaths = FilePaths()
    private let metricsAdapter: MetricsAdapter
    private let performanceMeasurer: PerformanceMeasurer<String>
    let metricsSender: MetricSender
    let deviceInfoReader: DeviceInfoReader & LegacyDeviceInfoReader
    let retriesInfoStorage: RetriesInfoWriter & RetriesInfoReader

    private let configEndpointProvider: ConfigEndpointProvider

    init(settingsProvider: NetworkSettingsProvider,
         configurationProvider: ConfigProvider,
         deviceInfoReader: DeviceInfoReader & LegacyDeviceInfoReader,
         performanceMeasurer: PerformanceMeasurer<String>,
         logger: Logger,
         retriesInfoStorage: RetriesInfoWriter & RetriesInfoReader) {
        self.configurationProvider = configurationProvider
        self.deviceInfoReader = deviceInfoReader
        self.allowedCodes = settingsProvider.responseSuccessCodes
        mainSession = URLSession(configuration: settingsProvider.mainSessionConfiguration,
                                 delegate: metricsCollector,
                                 delegateQueue: nil)
        metricSession = URLSession(configuration: settingsProvider.metricSessionConfiguration)
        self.metricsAdapter = MetricsAdapter(deviceInfoReader: deviceInfoReader,
                                             metricsMetaDataReader: self.configurationProvider,
                                             allowedResourceTypes: settingsProvider.metricsResourceTypes,
                                             retriesInfoReader: retriesInfoStorage)
        self.configEndpointProvider = EndpointProviderBase(worldZoneReader: WorldZoneReaderBase(countryCodeProvider: deviceInfoReader))
        metricsSender = createMetricsSender(session: metricSession,
                                            configProvider: configurationProvider,
                                            metricsAdapter: self.metricsAdapter,
                                            deviceInfoReader: deviceInfoReader,
                                            logger: logger)
        self.performanceMeasurer = performanceMeasurer
        self.retriesInfoStorage = retriesInfoStorage
    }

    var webViewDownLoader: WebViewDownloader {
        webViewDownloaderBuilder.webViewDownloader
    }

    var webViewDownloaderBuilder: WebViewDownloadBuilder {
        WebViewDownloadBuilder(unityAdsDownloader: unityAdsDownloader,
                               webViewDestination: filePaths.webviewURL,
                               retriesInfoWriter: retriesInfoStorage)
    }

}

extension UnityAdsNetworkServicesFactory: UnityAdsNetworkSenderProvider {

    func networkSender(includeRetryLogic: Bool,
                       collectCompressionMetrics: Bool) -> UnityAdsNetworkSender {
        let retryConfig = includeRetryLogic ? configurationProvider.networkConfig.request.retry : nil
        let networkSender = coreNetworkServicesBuilder.sender(withAllowedCodes: allowedCodes,
                                                              retryConfig: retryConfig)
        return UnityAdsNetworkSenderBase(factory: unityAdsRequestFactory(collectCompressionMetrics: collectCompressionMetrics),
                                         networkSender: networkSender)
    }
}

/**
 Objc specific network layers.
 used from the objc side through a bridge
 */
extension UnityAdsNetworkServicesFactory {
    var unityAdsWebViewNetwork: UnityAdsWebViewNetwork {
        .init(networkSender: coreNetworkServicesBuilder.sender(withAllowedCodes: [], retryConfig: nil),
              networkDownloader: coreNetworkServicesBuilder.downloader(withAllowedCodes: [], baseDirectory: filePaths.baseDir, retryConfig: nil))
    }

    var unityAdsNativeNetwork: UnityAdsWebViewNetwork {
        .init(networkSender: coreNetworkServicesBuilder.sender(withAllowedCodes: allowedCodes, retryConfig: nil),
              networkDownloader: coreNetworkServicesBuilder.downloader(withAllowedCodes: [], baseDirectory: filePaths.baseDir, retryConfig: nil))
    }

    var unityAdsMetricsNativeNetwork: UnityAdsWebViewNetwork {
        .init(networkSender: metricsNetworkServicesBuilder.sender(withAllowedCodes: allowedCodes, retryConfig: nil),
              networkDownloader: metricsNetworkServicesBuilder.downloader(withAllowedCodes: [], baseDirectory: filePaths.baseDir, retryConfig: nil))
    }
}

extension UnityAdsNetworkServicesFactory {

    private func unityAdsRequestFactory(collectCompressionMetrics: Bool) -> UnityAdsRequestFactory {
        .init(configurationProvider: configurationProvider,
              adapter: metricsAdapter,
              deviceInfoReader: deviceInfoReader,
              bodyCompressor: bodyCompressor(includeMetrics: collectCompressionMetrics))
    }

    private func bodyCompressor(includeMetrics: Bool) -> DataCompressor {
        let original = GZipCompressor()
        return includeMetrics ? DataCompressorWithMetrics(original: original,
                                                          measurer: performanceMeasurer,
                                                          metricsSender: metricsSender) : original

    }

    private var metricsNetworkBuilder: NetworkSenderBuilder {
        metricsNetworkServicesBuilder.createNetworkSenderBuilder(with: allowedCodes)
    }

    private var unityAdsDownloader: UnityAdsNetworkDownloader {
        let downloader = coreNetworkServicesBuilder.downloader(withAllowedCodes: allowedCodes,
                                                               baseDirectory: filePaths.baseDir,
                                                               retryConfig: configurationProvider.webViewConfig.retry)
        return UnityAdsNetworkDownloaderBase(factory: unityAdsRequestFactory(collectCompressionMetrics: false),
                                             downloader: downloader)
    }

    private var coreNetworkServicesBuilder: CoreNetworkServicesBuilder {
        .init(session: mainSession,
              configurationProvider: configurationProvider,
              metricsCollector: metricsCollector,
              metricsSender: metricsSender)
    }

    private var metricsNetworkServicesBuilder: CoreNetworkServicesBuilder {
        .init(session: metricSession,
              configurationProvider: configurationProvider,
              metricsCollector: nil,
              metricsSender: nil)
    }

}

private func createMetricsSender(session: URLSession,
                                 configProvider: UnityAdsConfigurationProvider & MetricsSenderBatchConditionSubject,
                                 metricsAdapter: MetricsAdapter,
                                 deviceInfoReader: DeviceInfoReader & LegacyDeviceInfoReader,
                                 logger: Logger,
                                 codes: [Int] = Array((200...299))) -> MetricSender {

    let networkBuilder = CoreNetworkServicesBuilder(session: session,
                                                    configurationProvider: configProvider,
                                                    metricsCollector: nil,
                                                    metricsSender: nil)

    let unityAdsRequestFactory = UnityAdsRequestFactory(configurationProvider: configProvider,
                                                        adapter: metricsAdapter,
                                                        deviceInfoReader: deviceInfoReader,
                                                        bodyCompressor: GZipCompressor())
    let networkSenderBuilder = networkBuilder.createNetworkSenderBuilder(with: codes)

    let metricsSenderBuilder =  MetricsSenderBuilder(metricsConfigReader: configProvider,
                                                     unityAdsRequestFactory: unityAdsRequestFactory,
                                                     networkBuilder: networkSenderBuilder,
                                                     conditionSubject: configProvider,
                                                     logger: logger,
                                                     metricAdapter: metricsAdapter)
    return metricsSenderBuilder.networkDiagnosticMetricsSender
}
