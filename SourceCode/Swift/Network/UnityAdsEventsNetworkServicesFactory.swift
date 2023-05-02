import Foundation

protocol MetricsSenderProvider {
    var metricsSender: MetricSender { get }
}
protocol DiagnosticMetricsSenderProvider {
    var diagnosticMetricSender: MetricSender { get }
}

final class UnityAdsEventsNetworkServicesFactory: MetricsSenderProvider, DiagnosticMetricsSenderProvider {

    let metricsSender: MetricSender
    let diagnosticMetricSender: MetricSender
    let config: Config
    let urlSession: URLSession
    init(config: Config) {
        self.config = config
        urlSession = URLSession(configuration: config.settingsReader.metricSessionConfiguration)
        let networkBuilder = CoreNetworkServicesBuilder(session: urlSession,
                                                        configurationProvider: config.configProvider,
                                                        metricsCollector: nil,
                                                        metricsSender: nil)

        let metricsAdapter = MetricsAdapter(deviceInfoReader: config.uiDeviceInfoProvider,
                                            telephonyProvider: config.teleponyProvider,
                                            metricsMetaDataReader: config.metricsDataReader,
                                            allowedResourceTypes: config.settingsReader.metricsResourceTypes,
                                            retriesInfoReader: config.retriesReader,
                                            gameSettingsReader: config.settingsReader,
                                            sessionId: config.sessionInfoReader.sessionID)
        let factoryConfig = UnityAdsEventsRequestFactory.Config(configurationProvider: config.configProvider,
                                                                metricsAdapter: metricsAdapter)
        let networkSenderBuilder = networkBuilder.createNetworkSenderBuilder(with: config.codes)

        let factory = UnityAdsEventsRequestFactory(config: factoryConfig)
        let metricsSenderBuilder =  MetricsSenderBuilder(metricsConfigReader: config.configProvider,
                                                         unityAdsRequestFactory: factory,
                                                         networkBuilder: networkSenderBuilder,
                                                         conditionSubject: config.configProvider,
                                                         logger: config.logger,
                                                         metricAdapter: metricsAdapter)

        metricsSender = metricsSenderBuilder.metricsSender
        diagnosticMetricSender = metricsSenderBuilder.networkDiagnosticMetricsSender
    }
}

extension UnityAdsEventsNetworkServicesFactory {
    var unityAdsMetricsNativeNetwork: UnityAdsWebViewNetwork {
        .init(networkSender: metricsNetworkServicesBuilder.sender(withAllowedCodes: config.codes, retryConfig: nil),
              networkDownloader: metricsNetworkServicesBuilder.downloader(withAllowedCodes: [],
                                                                          baseDirectory: config.filePaths.baseDir,
                                                                          retryConfig: nil))
    }

    private var metricsNetworkServicesBuilder: CoreNetworkServicesBuilder {
        .init(session: urlSession,
              configurationProvider: config.configProvider,
              metricsCollector: nil,
              metricsSender: nil)
    }
}

extension UnityAdsEventsNetworkServicesFactory {
    struct Config {
        let configProvider: UnityAdsConfigurationProvider & MetricsSenderBatchConditionSubject
        let uiDeviceInfoProvider: UIDeviceInfoProvider = UIDevice.current
        let metricsDataReader: ExperimentsReader & SessionTokenReader
        let retriesReader: RetriesInfoReader
        let logger: Logger
        let settingsReader: NetworkSettingsProvider & SDKGameSettingsProvider
        var sessionInfoReader: SessionInfoReader
        var codes: [Int] = Array((200...299))
        var filePaths: FilePaths = FilePaths()
        var teleponyProvider: TelephonyNetworkStatusProvider = TelephonyNetworkStatusProvider()
    }
}
