// import XCTest
// @testable import UnityAds
//
// final class InitializationTasksPerformanceE2ETests: SDKInitializerLegacyIntegrationTestsBase {
//    let timeout: TimeInterval = 50
//
//    func test_config_fetch_legacy_flow() {
//        measureMetrics([.wallClockTime],
//                       automaticallyStartMeasuring: false,
//                       for: {
//            runTestFlow(with: [:], tasks: [.sync(.configFetch)])
//        })
//    }
//
//    func test_config_fetch_legacy_flow_swift_requests() {
//        measureMetrics([.wallClockTime],
//                       automaticallyStartMeasuring: false,
//                       for: {
//            runTestFlow(with: ["s_nrq": true, "s_wvrq": true], tasks: [.sync(.configFetch)])
//        })
//    }
//
//    func test_config_fetch_new_task_implementation() {
//        measureMetrics([.wallClockTime],
//                       automaticallyStartMeasuring: false,
//                       for: {
//            runTestFlow(with: ["s_ntf": true], tasks: [.sync(.configFetch)])
//        })
//    }
//
//    func test_web_download_task_legacy_old_implementation() {
//        measureMetrics([.wallClockTime],
//                       automaticallyStartMeasuring: false,
//                       for: {
//            runTestFlow(with: [:], tasks: [.sync(.webViewDownload)])
//        })
//
//    }
//
//    func runTestFlow(with experiments: [String: Bool],
//                     overrideJSON: [String: Any] = [:],
//                     tasks: [InitTaskCategory]) {
//        do {
//            resetTester()
//            try setUpFlow(with: experiments, overrideJSON: overrideJSON)
//            let exp = defaultExpectation
//            startMeasuring()
//
//            let factory = serviceProvider.initTaskFactory
//            let runner = factory.task(of: tasks[0])
//            DispatchQueue.global().async {
//                runner.start { result in
//                    self.stopMeasuring()
//                    exp.fulfill()
//                    XCTAssertSuccess(result)
//
//                }
//            }
//
//            wait(for: [exp], timeout: timeout)
//        } catch {
//            XCTFail(error.localizedDescription)
//        }
//    }
//
//    private var serviceProvider: UnityAdsServiceProvider {
//        guard let proxy = UADSServiceProviderContainer.sharedInstance().serviceProvider.objBridge.proxyObject as? ServiceProviderObjCBridge else {
//            fatalError()
//        }
//        return proxy.serviceProvider
//    }
//
//    func setUpFlow(with experiments: [String: Bool],
//                   overrideJSON: [String: Any] = [:]) throws {
//        tester.deleteConfigurationFile()
//        let config = try configMockFactory.defaultUnityAdsConfig(experiments: experiments,
//                                                                 overrideJSON: overrideJSON)
//        try configMockFactory.saveConfigToFile(config)
//
//        UADSServiceProviderContainer.sharedInstance().serviceProvider = .init()
//        serviceProvider.legacyStateFactory = UADSServiceProviderContainer.sharedInstance().serviceProvider.stateFactory
//    }
//
// }
