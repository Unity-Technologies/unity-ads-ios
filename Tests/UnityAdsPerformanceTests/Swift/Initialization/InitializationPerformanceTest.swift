import XCTest
@testable import UnityAds

@available(iOS 13.0, *)
final class InitializationPerformanceTest: SDKInitializerLegacyIntegrationTestsBase {

    let gameID = "14850"
    let iterationCount = 10

    override var useExampleConfig: Bool {
        return true
    }

    var measurable: Bool = true

    override var sut: SDKInitializer {
        let sut = UnityAdsInitializeWrapper()
        if measurable {
            sut.onStart = { [weak self] in self?.startMeasuring() }
            sut.onFinish = { [weak self] in self?.stopMeasuring() }
        }
        return sut

    }
    override func setUpWithError() throws {
        try super.setUpWithError()
        USRVInitializeStateCreate.setMocked(true)
    }

    override func tearDown() {
        super.tearDown()
        USRVInitializeStateCreate.setMocked(false)
        UADSServiceProviderContainer.sharedInstance().serviceProvider = .init()
    }

    func test_get_token_during_swift_legacy_initializing() throws {
        try run_get_token_during_initializing(with: ["s_init": true],
                                              metrics: ExpectedMetrics.NewInitLegacyFlow.HappyPath,
                                              expectedDiagnostic: false)
    }

    func test_get_token_during_swift_new_task_initializing() throws {
        try run_get_token_during_initializing(with: ["s_init": true, "s_ntf": true],
                                              metrics: ExpectedMetrics.SequentialFlow.HappyPath,
                                              expectedDiagnostic: true)
    }

    func test_get_token_during_swift_parallel_initializing() throws {
        try run_get_token_during_initializing(with: ["s_init": true, "s_pte": true],
                                              metrics: ExpectedMetrics.ParallelFlow.HappyPath,
                                              expectedDiagnostic: true)
    }

    func run_get_token_during_initializing(with experiments: [String: Bool],
                                           metrics: [SDKMetricType],
                                           expectedDiagnostic: Bool) throws {
        measurable = false
        let exp = defaultExpectation
        var metrics = metrics
        metrics.append(contentsOf: [
            .legacy(.nativeTokenAvailable),
            .legacy(.latency(.intoCollection)),
            .legacy(.latency(.infoCompression))])
        try? runFlow(sdkMetrics: metrics,
                     experiments: experiments,
                     expectNetworkDiagnostic: expectedDiagnostic,
                     legacyFlow: true,
                     parallelToInit: {
            UnityAds.getToken { token in
                XCTAssertNotNil(token)
                exp.fulfill()
            }
        })

        wait(for: [exp], timeout: defaultTimeout)
    }

    func test_e2e_initialization_performance_legacy_flow() throws {
        measure(metrics: metrics,
                options: testOptions) {
            try? runFlow(sdkMetrics: ExpectedMetrics.LegacyFlow.HappyPath,
                         experiments: [:],
                         expectNetworkDiagnostic: false,
                         legacyFlow: true)
        }
    }

    func test_initialization_performance_new_init_legacy_flow() throws {
        measure(metrics: metrics,
                options: testOptions) {
            try? runFlow(sdkMetrics: ExpectedMetrics.NewInitLegacyFlow.HappyPath,
                         experiments: ["s_init": true],
                         expectNetworkDiagnostic: false)
        }

    }

    func test_e2e_initialization_performance_new_init_seq_flow() throws {
        measure(metrics: metrics,
                options: testOptions) {
            try? runFlow(sdkMetrics: ExpectedMetrics.SequentialFlow.HappyPath,
                         experiments: ["s_init": true, "s_ntf": true],
                         expectNetworkDiagnostic: true)
        }

    }

    func test_e2e_initialization_performance_new_init_parallel_flow() throws {
        measure(metrics: metrics,
                options: testOptions) {
            try? runFlow(sdkMetrics: ExpectedMetrics.ParallelFlow.HappyPath,
                         experiments: ["s_init": true, "s_pte": true],
                         expectNetworkDiagnostic: true)
        }
    }

}

@available(iOS 13.0, *)
extension InitializationPerformanceTest {

    func prepareForTheFlow(for legacy: Bool = false,
                           with experiments: [String: Bool],
                           overrideJSON: [String: Any] = [:]) throws {
        try setLegacyConfig(with: experiments, overrideJSON: overrideJSON)
        setupServiceProviderWithMocks()
        UADSServiceProviderContainer.sharedInstance().serviceProvider = tester.uadsServiceProvider
        tester.testingLegacyFlow = legacy

    }
    func runFlow(sdkMetrics: [SDKMetricType],
                 experiments: [String: Bool],
                 expectNetworkDiagnostic: Bool,
                 legacyFlow: Bool = false,
                 parallelToInit: VoidClosure? = nil,
                 line: UInt = #line,
                 file: StaticString = #file) throws {
        let overrideJson = ["hash": configMockFactory.longWebViewDataDataHash]
        try prepareForTheFlow(for: legacyFlow, with: experiments, overrideJSON: overrideJson)
        let returnedConfigData = try configMockFactory.defaultConfigData(experiments: experiments,
                                                                         overrideJSON: overrideJson)
        let privacyData = returnedConfigData
        let expectedConfig = try configMockFactory.defaultUnityAdsConfig(experiments: experiments,
                                                                         overrideJSON: overrideJson)
        let responses: [URLProtocolResponseStub] = [
            .init(data: privacyData),
            .init(data: returnedConfigData),
            .init(data: configMockFactory.longWebViewData,
                  url: expectedConfig.network.webView.url)
        ]

        let testConfig = TestConfig(responses: responses,
                                    sdkConfig: expectedConfig,
                                    expectedNumberOfRequests: responses.count,
                                    multithreadCount: 1,
                                    metrics: sdkMetrics,
                                    expectDiagnostic: expectNetworkDiagnostic)
        try executeTest(with: testConfig,
                        file: file,
                        line: line,
                        resultValidation: { XCTAssertSuccess($0) },
                        final: {

            XCTAssertEqual(self.tester.sdkState, .initialized, file: file, line: line)
        }, parallelToInit: parallelToInit)

        resetTestSetup()
    }

    func setLegacyConfig(with experiments: [String: Bool],
                         overrideJSON: [String: Any] = [:]) throws {
        USRVWebViewApp.setCurrent(nil)
        tester.deleteConfigurationFile()
        let config = try configMockFactory.defaultUnityAdsConfig(experiments: experiments,
                                                                 overrideJSON: overrideJSON)
        try configMockFactory.saveConfigToFile(config)
    }

    func setupServiceProviderWithMocks() {
        tester.uadsServiceProvider.webViewRequestFactory = WebRequestFactoryMock(urlSession: .init(configuration: tester.urlSessionConfiguration))

        tester.uadsServiceProvider.metricsRequestFactory = metricsWebRequestFactoryMock
        let fMock = USRVInitializeStateFactoryMock()
        fMock.original = tester.uadsServiceProvider.stateFactory
        tester.uadsServiceProvider.stateFactory = fMock
    }

    func resetTestSetup() {
        UnityAds.resetForTest()
        resetTester()
        USRVSdkProperties.setDebugMode(false)
    }

    var metricsWebRequestFactoryMock: WebRequestFactoryMock {
        return .init(allowReturningEmptyData: true,
                     urlSession: URLSession(configuration: tester.metricURLSessionConfiguration))
    }

    var testOptions: XCTMeasureOptions {
        let options = XCTMeasureOptions()
        options.iterationCount = iterationCount
        options.invocationOptions = [.manuallyStart, .manuallyStop]
        return options
    }

    var metrics: [XCTMetric] {
        [
            XCTClockMetric()
        ]
    }

}
