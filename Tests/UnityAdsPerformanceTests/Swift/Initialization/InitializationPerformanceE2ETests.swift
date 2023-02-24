// import XCTest
//
// @testable import UnityAds
//
// final class InitializationPerformanceE2ETests: SDKInitializerLegacyIntegrationTestsBase {
//
//    let gameID = "14850"
//    let iterationCount = 20
//    let timeout: TimeInterval = 50
//
//    func test_e2e_initialization_performance_legacy_flow() throws {
//        try setUpFlow(with: [:])
//        measureMetrics([.wallClockTime],
//                       automaticallyStartMeasuring: false,
//                       for: {
//            runTestFlow(with: [:])
//        })
//
//    }
//
//    func test_e2e_initialization_performance_legacy_flow_new_web_download() throws {
//        try setUpFlow(with: ["s_wd": true])
//        measureMetrics([.wallClockTime],
//                       automaticallyStartMeasuring: false,
//                       for: {
//            runTestFlow(with: [:])
//        })
//
//    }
//
//    func test_e2e_initialization_performance_new_init_legacy_flow() throws {
//
//        measureMetrics([.wallClockTime],
//                       automaticallyStartMeasuring: false,
//                       for: {
//            runTestFlow(with: ["s_init": true])
//        })
//    }
//
//    func test_e2e_initialization_performance_new_init_seq_flow() throws {
//        measureMetrics([.wallClockTime],
//                       automaticallyStartMeasuring: false,
//                       for: {
//            runTestFlow(with: ["s_init": true, "s_ntf": true])
//        })
//    }
//
//    func test_e2e_initialization_performance_new_init_parallel_flow() throws {
//
//        measureMetrics([.wallClockTime],
//                       automaticallyStartMeasuring: false,
//                       for: {
//            runTestFlow(with: ["s_init": true, "s_pte": true])
//        })
//    }
//
//    func setUpFlow(with experiments: [String: Bool],
//                   overrideJSON: [String: Any] = [:]) throws {
//        USRVWebViewApp.setCurrent(nil)
//        tester.deleteConfigurationFile()
//        let config = try configMockFactory.defaultUnityAdsConfig(experiments: experiments,
//                                                                 overrideJSON: overrideJSON)
//        try configMockFactory.saveConfigToFile(config)
//    }
//
//    func runTestFlow(with experiments: [String: Bool],
//                     overrideJSON: [String: Any] = [:]) {
//        do {
//            try setUpFlow(with: experiments, overrideJSON: overrideJSON)
//            let delegate = UnityAdsDelegateWrapper()
//            let exp = defaultExpectation
//            prepareForTests(with: exp, delegate: delegate)
//            startMeasuring()
//            UnityAds.initialize(gameID, initializationDelegate: delegate)
//            wait(for: [exp], timeout: timeout)
//        } catch {
//            XCTFail(error.localizedDescription)
//        }
//    }
//
//    func prepareForTests(with exp: XCTestExpectation,
//                         delegate: UnityAdsDelegateWrapper) {
//        resetTester()
//        UnityAds.resetForTest()
//        delegate.complete = {
//            self.stopMeasuring()
//            exp.fulfill()
//        }
//        delegate.failure = { error in
//            self.stopMeasuring()
//            XCTFail(error)
//            exp.fulfill()
//        }
//        URLCache.shared.removeAllCachedResponses()
//        UADSServiceProviderContainer.sharedInstance().serviceProvider = .init()
//    }
//
// }
