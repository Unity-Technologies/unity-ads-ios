import Foundation

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
final class UnityAdsNetworkServicesFactory {
    typealias ConfigProvider = UnityAdsConfigurationProvider &
                               MetricsSenderBatchConditionSubject &
                               ExperimentsReader &
                               SessionTokenReader &
                               RetriesInfoStorage
    typealias SettingsProvider = LoggerSettingsReader &
                                 NetworkSettingsProvider &
                                 SDKGameSettingsProvider

    private let configurationProvider: ConfigProvider
    private let metricsCollector: URLSessionTaskMetricCollector = URLSessionTaskMetricCollectorBase()
    private var mainSession: URLSession
    private let allowedCodes: [Int]
    private let filePaths = FilePaths()
    private let performanceMeasurer: PerformanceMeasurer<String>
    let metricSenderProvider: MetricsSenderProvider & DiagnosticMetricsSenderProvider
    let deviceInfoReaderProvider: DeviceInfoBodyReaderProvider

    private let configEndpointProvider: ConfigEndpointProvider
    private let telephonyProvider: TelephonyNetworkStatusProvider
    init(settingsProvider: SettingsProvider,
         configurationProvider: ConfigProvider,
         deviceInfoReaderProvider: DeviceInfoBodyReaderProvider,
         performanceMeasurer: PerformanceMeasurer<String>,
         logger: Logger,
         metricSenderProvider: MetricsSenderProvider & DiagnosticMetricsSenderProvider,
         telephonyProvider: TelephonyNetworkStatusProvider = TelephonyNetworkStatusProvider()) {
        self.configurationProvider = configurationProvider
        self.deviceInfoReaderProvider = deviceInfoReaderProvider
        self.allowedCodes = settingsProvider.responseSuccessCodes
        self.telephonyProvider = telephonyProvider
        mainSession = URLSession(configuration: settingsProvider.mainSessionConfiguration,
                                 delegate: metricsCollector,
                                 delegateQueue: nil)
        let deviceInfoReader = deviceInfoReaderProvider.deviceInfoBodyReader
        self.configEndpointProvider = EndpointProviderBase(worldZoneReader: WorldZoneReaderBase(countryCodeProvider: telephonyProvider))

        self.metricSenderProvider = metricSenderProvider
        self.performanceMeasurer = performanceMeasurer
    }
}

extension UnityAdsNetworkServicesFactory {

    var webViewDownLoader: WebViewDownloader {
        webViewDownloaderBuilder.webViewDownloader
    }

    var webViewDownloaderBuilder: WebViewDownloadBuilder {
        WebViewDownloadBuilder(unityAdsDownloader: unityAdsDownloader,
                               webViewDestination: filePaths.webviewURL,
                               retriesInfoWriter: configurationProvider)
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

}

extension UnityAdsNetworkServicesFactory {

    private func unityAdsRequestFactory(collectCompressionMetrics: Bool) -> UnityAdsRequestFactory {
        .init(config: .init(configurationProvider: configurationProvider,
                            deviceInfoReaderProvider: deviceInfoReaderProvider,
                            bodyCompressor: bodyCompressor(includeMetrics: collectCompressionMetrics),
                            countryCodeProvider: telephonyProvider))
    }

    private func bodyCompressor(includeMetrics: Bool) -> DataCompressor {
        let original = GZipCompressor()
        return includeMetrics ? DataCompressorWithMetrics(original: original,
                                                          measurer: performanceMeasurer,
                                                          metricsSender: metricSenderProvider.metricsSender) : original

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
              metricsSender: metricSenderProvider.diagnosticMetricSender)
    }
}
