import Foundation
import XCTest

@testable import UnityAds

class SDKInitializerLegacyIntegrationTestsBase: XCMultiThreadTestCase {
    let defaultTimeout: TimeInterval = 1
    let concurrentQueue = DispatchQueue(label: "SDKInitializerLegacyIntegrationTestsBase.queue",
                                        qos: .background,
                                        attributes: .concurrent)
    var tester: SDKNetworkTestsHelper {
        guard let tester = _tester else {
            fatalError()
        }

        return tester
    }

    private var _tester: SDKNetworkTestsHelper?
    var sut: SDKInitializer { tester.serviceProvider.sdkInitializer }
    var configMockFactory: SDKConfigFactoryMock { .init(useConfigExample: useExampleConfig) }

    var useExampleConfig: Bool {
        false
    }

    override func setUpWithError() throws {
        let config = try configMockFactory.defaultUnityAdsConfig(experiments: defaultExperiments)
        try saveConfigToFile(config)
        resetTester()
    }

    func resetTester() {
        _tester = .init(useExampleConfig: useExampleConfig)
    }

    override func tearDown() {
        USRVApiSdk.setServiceProviderForTesting(UADSServiceProvider())
    }

    func saveConfigToFile(_ config: UnityAdsConfig) throws {
        try configMockFactory.saveConfigToFile(config)

    }

    override func tearDownWithError() throws {
        tester.deleteConfigurationFile()
    }

}

extension SDKInitializerLegacyIntegrationTestsBase {

    func createSimilarRequests(numberOfRequests: Int,
                               data: Data? = nil,
                               status: Int = 200,
                               error: Error? = nil,
                               url: String? = nil) -> [URLProtocolResponseStub] {
        stride(from: 0,
               to: numberOfRequests,
               by: 1).map({ _ in .init(data: data, status: status, error: error, url: url) })

    }

    func executeTest(with config: TestConfig,
                     file: StaticString = #filePath,
                     line: UInt = #line,
                     resultValidation: @escaping ResultClosure<Void>,
                     final: VoidClosure? = nil,
                     parallelToInit: VoidClosure? = nil) throws {
        let expectation = defaultExpectation
        var types = config.metrics
        if config.expectDiagnostic {
            types.append(contentsOf: tester.expectedNetworkMetrics(numberOfRequests: config.expectedNumberOfRequests))
        }

        let additionalFulfillmentCount = types.isEmpty ? 0 : 1
        expectation.expectedFulfillmentCount = config.multithreadCount + additionalFulfillmentCount
        let validator = tester.metricsValidator

        tester.metricProtocolStub.requestObserver = { [weak validator]_ in
            guard let validator = validator else { fatalError() }

            if validator.receivedCount >= types.count {
                expectation.fulfill()
            }
        }
        setNetworkResponses(config.responses)

        multiThreadTest(stressCount: config.multithreadCount,
                        using: expectation) { [weak self] expectation in
            self?.sut.initialize(with: config.initializeConfig) { result in
                resultValidation(result)
                expectation.fulfill()
            }
            parallelToInit?()
        }

        try tester.expectedLegacy(metrics: types, file: file, line: line)
        try tester.validateExpectedTags(for: types,
                                        configRetried: config.configRetried,
                                        webViewRetried: config.webviewRetried,
                                        file: file,
                                        line: line)
        XCTAssertEqual(tester.networkRequests.count, config.expectedNumberOfRequests, file: file, line: line)
//        XCTAssertEqual(self.tester.serviceProvider.sdkStateStorage.config,
//                       config.sdkConfig,
//                       file: file,
//                       line: line)
        final?()

    }

    var defaultExperiments: [String: Bool] {
        [
            "s_wd": true,
            "s_nrq": true,
            "s_wvrq": true,
            "s_init": true
        ]
    }

    func setNetworkResponses(_ stubs: [URLProtocolResponseStub]) {
        stubs.forEach(tester.addExpectedMainResponseStub)
    }

    struct TestConfig {
        let responses: [URLProtocolResponseStub]
        var initializeConfig: SDKInitializerConfig = .init(gameID: "GameID")
        let sdkConfig: UnityAdsConfig
        var expectedNumberOfRequests: Int = 0
        var multithreadCount: Int = 1
        var metrics: [SDKMetricType] = []
        var configRetried = 0
        var webviewRetried = 0
        var expectDiagnostic: Bool = true
    }

    func verifyWebExposedGetTrrData(_ config: UnityAdsConfig) {
        let exp = defaultExpectation
        let callbackMock = USRVWebViewCallbackMock.newSwiftCompletion { result in
            self.assertCallbackResult(result, config: config)
            exp.fulfill()
        }
        USRVApiSdk.webViewExposed_getTrrData(callbackMock)
        wait(for: [exp], timeout: defaultTimeout)
    }

    private func assertCallbackResult(_ result: [Any], config: UnityAdsConfig) {
        if let received = result.first as? [String: Any] {
            XCTAssertEqual(config.legacy, try? LegacySDKConfig(dictionary: received))
            XCTAssertNotNil(received["SRR"])
        } else {
            XCTFail("Didn't receive config data with WebViewExposed_getTrrData")
        }
    }
}

extension LegacySDKConfig: Equatable {
    public static func == (lhs: LegacySDKConfig, rhs: LegacySDKConfig) -> Bool {
        lhs.json.sortedDescription == rhs.json.sortedDescription

    }

}
