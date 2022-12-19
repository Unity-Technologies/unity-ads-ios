import Foundation

@testable import UnityAds

final class SDKNetworkTestsHelper {
    private(set) var protocolStub: URLProtocolMainNetworkStub.Type = URLProtocolMainNetworkStub.self

    private(set) var metricProtocolStub: URLProtocolMetricsNetworkStub.Type = URLProtocolMetricsNetworkStub.self

    var uadsServiceProvider: UADSServiceProvider

    let initStateFactoryMock = USRVInitializeStateFactoryMock()

    var sdkState: SDKInitializerBase.State {
        get { serviceProvider.sdkStateStorage.currentState }
        set { serviceProvider.sdkStateStorage.currentState = newValue }
    }

    var objServiceProvider: ServiceProviderObjCBridge {
            guard let bridge = uadsServiceProvider.objBridge.proxyObject as? ServiceProviderObjCBridge else {
                fatalError()
            }
            return bridge

    }

    var serviceProvider: UnityAdsServiceProvider

    var urlSessionConfiguration: URLSessionConfiguration = .default

    var metricURLSessionConfiguration: URLSessionConfiguration = .default

    var configFactoryMock: SDKConfigFactoryMock { .init() }

    var metricsValidator: SDKMetricsValidator {
        .init(stub: metricProtocolStub)
    }

    var networkRequests: [URLRequest] {
        protocolStub.requests
    }

    var metricsRequests: [URLRequest] {
        metricProtocolStub.requests
    }

    var webViewFakeData: Data {
        "webViewFakeData".data(using: .utf8) ?? .init()
    }

    var webViewFakeDataPrivacy: Data {
        "webViewFakeDataFromPrivacy".data(using: .utf8) ?? .init()
    }
    var webViewFakeDataPrivacyHash: String {
        "a711a027fcc404981b18c68f625aeeda4d99bc03e30c0f6dc6a02f56fdfa02fd"
    }

    init() {
        // this is the entry point of our legacy code that contains
        // objc bridge to our swift service provider
        uadsServiceProvider = UADSServiceProvider()
        urlSessionConfiguration.protocolClasses = [protocolStub]
        metricURLSessionConfiguration.protocolClasses = [metricProtocolStub]
        let settings = SDKSettingsStorage()
        settings.mainSessionConfiguration = urlSessionConfiguration
        settings.metricSessionConfiguration = metricURLSessionConfiguration
        settings.metricsResourceTypes = [] // include all types
        settings.allowDumpToFile = false
        settings.currentLevel = .fatal
        serviceProvider = .init(skdSettingsStorage: settings)
        serviceProvider.legacyStateFactory = initStateFactoryMock
        initStateFactoryMock.original = uadsServiceProvider.stateFactory()

        // replacing generated swift service provider with a new one that contains mocked url protocols
        objServiceProvider.serviceProvider = serviceProvider

        resetStubs()
        resetCache()
        serviceProvider.sdkStateStorage.config = .default
        serviceProvider.skdSettingsStorage.currentInitConfig = .init(gameID: "")
        serviceProvider.sdkStateStorage.currentState = .notInitialized

        USRVApiSdk.setServiceProviderForTesting(uadsServiceProvider)
    }

    func resetStubs() {
        protocolStub.clear()
        metricProtocolStub.clear()
    }

    func resetCache() {
//        deleteConfigurationFile()
        eraseWebViewDataCache()
        USRVWebViewApp.getCurrent()?.resetWebViewAppInitialization()
        USRVWebViewApp.setCurrent(nil)
    }

    func deleteConfigurationFile() {
        let path = USRVSdkProperties.getLocalConfigFilepath() ?? ""
        removeFile(at: path)
    }

    func updateInMemorySwiftConfig(_ config: UnityAdsConfig) {
        serviceProvider.sdkStateStorage.config = config
    }

    func eraseWebViewDataCache() {
        removeFile(at: serviceProvider.skdSettingsStorage.filePaths.webviewURL.path)
    }

    func saveDefaultFakeWebViewDataToFile() throws {
        try saveWebViewData(configFactoryMock.webViewFakeData)
    }

    func saveWebViewData(_ data: Data) throws {
        try data.write(to: .init(fileURLWithPath: serviceProvider.skdSettingsStorage.filePaths.webviewURL.path))
    }

    private func removeFile(at path: String) {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: path) else {
            return
        }
        try? fileManager.removeItem(atPath: path)
    }

    func addExpectedMainResponseStub(_ stub: URLProtocolResponseStub) {
        protocolStub.addExpectedStub(stub)
    }

    func setResponseExpectedData(_ data: Data?, at index: Int = 0) {
        protocolStub.setExpectedData(data, at: index)
    }

    func setResponseExpectedError(_ error: Error?, at  index: Int = 0) {
        protocolStub.setExpectedError(error, at: index)
    }

    func setResponseExpectedStatus(_ status: Int, at  index: Int = 0) {
        protocolStub.setExpectedStatus(status, at: index)
    }

    func addExpectedMetricsResponseStub(_ stub: URLProtocolResponseStub) {
        metricProtocolStub.addExpectedStub(stub)
    }

    func setMetricsResponseExpectedData(_ data: Data?, at  index: Int = 0) {
        metricProtocolStub.setExpectedData(data, at: index)
    }

    func setMetricsResponseExpectedError(_ error: Error?, at  index: Int = 0) {
        metricProtocolStub.setExpectedError(error, at: index)
    }

    func setMetricsResponseExpectedStatus(_ status: Int, at  index: Int = 0) {
        metricProtocolStub.setExpectedStatus(status, at: index)
    }

    func expectedNetworkMetrics(numberOfRequests: Int) -> [SDKMetricType] {
        stride(from: 0, to: numberOfRequests, by: 1).flatMap({ _ in defaultNetworkMetricTypes })
    }

    func expectedLegacy(metrics types: [SDKMetricType],
                        file: StaticString = #filePath,
                        line: UInt = #line) throws {
        try metricsValidator.expectedLegacy(metrics: types, file: file, line: line)
    }

    func validateExpectedTags(for metrics: [SDKMetricType],
                              configRetried: Bool,
                              webViewRetried: Bool,
                              file: StaticString = #filePath,
                              line: UInt = #line) throws {
        guard !metrics.isEmpty else { return }
        var tags: [String: String] = [:]
        if configRetried || webViewRetried {
            tags = ["c_retry": configRetried ? "true" : "false",
                    "wv_retry": webViewRetried ? "true" : "false"]
        }
        let withRetryTags = metrics.filter { type in
            switch type {
            case .taskPerformance, .requestPerformance: return true
            default: return false
            }
        }
        try metricsValidator.expectedTags(for: withRetryTags, tags: tags, file: file, line: line)
    }
}

extension SDKNetworkTestsHelper {

    private var defaultNetworkMetricTypes: [SDKMetricType] {
        [
            .network(.connectTime(0)),
            .network(.secureConnectTime(0)),
            .network(.domainLookup(0)),
            .network(.requestTime(0)),
            .network(.responseTime(0)),
            .network(.taskTime(0)),
            .network(.requestSize(0)),
            .network(.responseSize(0))
        ]
    }
}
