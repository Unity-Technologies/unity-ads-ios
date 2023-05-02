import XCTest
@testable import UnityAds

// swiftlint:disable type_body_length
// swiftlint:disable file_length

class SDKInitializerLegacyIntegrationTests: SDKInitializerLegacyIntegrationTestsBase {

    func test_init_finishes_with_success_when_config_and_web_view_are_available() throws {
        let returnedConfigData = try configMockFactory.defaultConfigData(experiments: defaultExperiments)
        let privacyData = returnedConfigData
        let expectedConfig = try configMockFactory.defaultUnityAdsConfig(experiments: defaultExperiments)
        let responses: [URLProtocolResponseStub] = [
            .init(data: privacyData),
            .init(data: returnedConfigData),
            .init(data: configMockFactory.webViewFakeData)
        ]

        let testConfig = TestConfig(responses: responses,
                                    sdkConfig: expectedConfig,
                                    expectedNumberOfRequests: responses.count,
                                    multithreadCount: 1,
                                    metrics: ExpectedMetrics.NewInitLegacyFlow.HappyPath,
                                    expectDiagnostic: true)
        try executeTest(with: testConfig,
                        resultValidation: { XCTAssertSuccess($0) },
                        final: {

            XCTAssertEqual(self.tester.sdkState, .initialized)
            self.verifyWebExposedGetTrrData(expectedConfig)
        })

    }

    func test_no_diagnostic_metrics_sent_when_config_flag_set_to_false() throws {
        let overrideJSON = ["ntwd": false]
        let returnedConfigData = try configMockFactory.defaultConfigData(experiments: defaultExperiments,
                                                                         overrideJSON: overrideJSON)
        let privacyData = returnedConfigData
        let expectedConfig = try configMockFactory.defaultUnityAdsConfig(experiments: defaultExperiments,
                                                                         overrideJSON: overrideJSON)

        let responses: [URLProtocolResponseStub] = [
            .init(data: privacyData),
            .init(data: returnedConfigData),
            .init(data: configMockFactory.webViewFakeData)
        ]

        var sdkMetrics: [SDKMetricType] =  [
            .legacy(.initStarted),
            .legacy(.latency(.infoCollection)),
            .legacy(.latency(.infoCompression)),
            .legacy(.missed(.token)),
            .legacy(.missed(.stateID)),
            .legacy(.latency(.privacyRequestSuccess)),
            .legacy(.latency(.configRequestSuccess))
        ]

        let sdkPerformanceMetrics: [SDKMetricType] = [
            .taskPerformance(.success(.loadLocalConfig)),
            .taskPerformance(.success(.initializer)),
            .taskPerformance(.success(.configFetch)),
            .taskPerformance(.success(.webViewDownload)),
            .taskPerformance(.success(.webViewCreate)),
            .taskPerformance(.success(.initModules)),
            .taskPerformance(.success(.reset)),
            .taskPerformance(.success(.complete))
        ]

        sdkMetrics += sdkPerformanceMetrics
        let testConfig = TestConfig(responses: responses,
                                    sdkConfig: expectedConfig,
                                    expectedNumberOfRequests: responses.count,
                                    multithreadCount: 1,
                                    metrics: sdkMetrics,
                                    expectDiagnostic: false)
        try executeTest(with: testConfig,
                        resultValidation: { XCTAssertSuccess($0) },
                        final: {

            XCTAssertEqual(self.tester.sdkState, .initialized)
            self.verifyWebExposedGetTrrData(expectedConfig)
        })

    }

    func test_init_fails_with_error_when_config_has_corrupted_data() throws {
        let corruptedConfig = try ["key": "value"].serializedData()
        let expectedConfig = try configMockFactory.defaultUnityAdsConfig(experiments: defaultExperiments)
        let expectedNumberOfRequests = expectedConfig.network.request.retry.maxCount + 1 // Config Request + retries

        let privacyResponsesData = try configMockFactory.defaultConfigData(experiments: defaultExperiments)
        let configResponses = createSimilarRequests(numberOfRequests: expectedNumberOfRequests,
                                                    data: corruptedConfig)

        let responses = [.init(data: privacyResponsesData)] + configResponses // Privacy is called once + all config responses inc retries
        var sdkMetrics: [SDKMetricType] =  [
            .legacy(.initStarted),
            .legacy(.latency(.privacyRequestSuccess))
        ]

        let configRequestMetrics: [SDKMetricType] = [
            .legacy(.latency(.infoCollection)),
            .legacy(.latency(.infoCompression)),
            .legacy(.latency(.configRequestFailure))

        ]
        let allConfigMetrics = stride(from: 0, to: configResponses.count, by: 1).flatMap({_ in
            configRequestMetrics
        })

        let sdkPerformanceMetrics: [SDKMetricType] = [
            .taskPerformance(.success(.loadLocalConfig)),
            .taskPerformance(.failure(.initializer)),
            .taskPerformance(.failure(.configFetch)),
            .taskPerformance(.success(.initModules)),
            .taskPerformance(.success(.reset))
        ]

        sdkMetrics += sdkPerformanceMetrics
        sdkMetrics += allConfigMetrics

        let testConfig = TestConfig(responses: responses,
                                    sdkConfig: expectedConfig,
                                    expectedNumberOfRequests: responses.count,
                                    multithreadCount: 1,
                                    metrics: sdkMetrics,
                                    configRetried: expectedConfig.network.request.retry.maxCount,
                                    expectDiagnostic: true)

        try executeTest(with: testConfig,
                        resultValidation: {
            XCTAssertFailure($0, expectedError: "Network error occured init SDK initialization, waiting for connection")
        })

    }

    func test_config_state_legacy_retries_n_number_of_times_and_fails() throws {

        let sut = tester.uadsServiceProvider.stateFactory.state(for: .configFetch)
        let expectation = defaultExpectation
        let defaultConfig = try configMockFactory.defaultUnityAdsConfig(experiments: defaultExperiments)
        let expectedNumberOfRequests = defaultConfig.network.request.retry.maxCount + 1
        let responses: [URLProtocolResponseStub] = stride(from: 0,
                                                       to: expectedNumberOfRequests,
                                                       by: 1).map({ _ in .init(status: 500) })

        setNetworkResponses(responses)

        sut.start {
            expectation.fulfill()
        } error: { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: defaultTimeout)
        XCTAssertEqual(tester.networkRequests.count, expectedNumberOfRequests)
        XCTAssertEqual(tester.serviceProvider.sdkStateStorage.config,
                       defaultConfig)
    }

    func test_init_fails_with_error_when_config_fetch_fails_no_fallback_no_metrics() throws {
        let expectedConfig = try configMockFactory.defaultUnityAdsConfig(experiments: defaultExperiments)
        let expectedNumberOfRequests = expectedConfig.network.request.retry.maxCount + 1
        let privacyResponsesData = try configMockFactory.defaultConfigData(experiments: defaultExperiments)
        let configResponses = createSimilarRequests(numberOfRequests: expectedNumberOfRequests, status: 500)
        let responses = [.init(data: privacyResponsesData)] + configResponses

        var sdkMetrics: [SDKMetricType] =  [
            .legacy(.initStarted),
            .legacy(.latency(.privacyRequestSuccess))
        ]

        let sdkPerformanceMetrics: [SDKMetricType] = [
            .taskPerformance(.success(.loadLocalConfig)),
            .taskPerformance(.failure(.configFetch)),
            .taskPerformance(.success(.initModules)),
            .taskPerformance(.success(.reset)),
            .taskPerformance(.failure(.initializer))
        ]

        let allConfigMetrics: [SDKMetricType] = stride(from: 0, to: configResponses.count, by: 1).flatMap({_ in
            [
                .legacy(.latency(.infoCollection)),
                .legacy(.latency(.infoCompression)),
                .legacy(.latency(.configRequestFailure))
            ]
        }) // since there is a a number of retries, the metrics are sent per every request. We expect N * configRequestMetrics

        sdkMetrics += sdkPerformanceMetrics
        sdkMetrics += allConfigMetrics
        let testConfig = TestConfig(responses: responses,
                                    sdkConfig: expectedConfig,
                                    expectedNumberOfRequests: responses.count,
                                    multithreadCount: 1,
                                    metrics: sdkMetrics,
                                    configRetried: expectedConfig.network.request.retry.maxCount,
                                    expectDiagnostic: true)

        try executeTest(with: testConfig,
                        resultValidation: {
            XCTAssertFailure($0, expectedError: "Network error occured init SDK initialization, waiting for connection")
        })
    }

    func test_init_fails_with_web_view_fetch_returns_invalid_file() throws {
        let returnedConfigData = try configMockFactory.defaultConfigData(experiments: defaultExperiments)
        let expectedConfig = try configMockFactory.defaultUnityAdsConfig(experiments: defaultExperiments)

        let privacyResponsesData = try configMockFactory.defaultConfigData(experiments: defaultExperiments)
        let responses: [URLProtocolResponseStub] = [
            .init(data: privacyResponsesData),
            .init(data: returnedConfigData),
            .init(data: returnedConfigData) // broken webview request
        ]

        let expectedNumberOfRequests = responses.count

        var sdkMetrics: [SDKMetricType] =  [
            .legacy(.initStarted),
            .legacy(.latency(.infoCollection)),
            .legacy(.latency(.infoCompression)),
            .legacy(.latency(.configRequestSuccess)),
            .legacy(.missed(.token)),
            .legacy(.missed(.stateID)),
            .legacy(.latency(.privacyRequestSuccess))

        ]

        let sdkPerformanceMetrics: [SDKMetricType] = [
            .taskPerformance(.success(.loadLocalConfig)),
            .taskPerformance(.success(.configFetch)),
            .taskPerformance(.success(.initModules)),
            .taskPerformance(.success(.reset)),
            .taskPerformance(.failure(.webViewDownload)),
            .taskPerformance(.failure(.initializer))
        ]

        sdkMetrics += sdkPerformanceMetrics

        let testConfig = TestConfig(responses: responses,
                                    sdkConfig: expectedConfig,
                                    expectedNumberOfRequests: expectedNumberOfRequests,
                                    multithreadCount: 1,
                                    metrics: sdkMetrics,
                                    expectDiagnostic: true)

        try executeTest(with: testConfig,
                        resultValidation: {
            XCTAssertFailure($0, expectedError: "Network error while loading WebApp from internet, waiting for connection")
        })
    }

    func test_init_fails_with_web_view_fetch_fails() throws {
        let returnedConfigData = try configMockFactory.defaultConfigData(experiments: defaultExperiments)
        let expectedConfig = try configMockFactory.defaultUnityAdsConfig(experiments: defaultExperiments)
        let webViewRetries = expectedConfig.network.webView.retry.maxCount
        let webViewResponseError = NSError(domain: "network", code: 500)
        let brokenRetriedRequests = createSimilarRequests(numberOfRequests: webViewRetries, error: webViewResponseError)
        let privacyResponsesData = try configMockFactory.defaultConfigData(experiments: defaultExperiments)
        var responses: [URLProtocolResponseStub] = [
            .init(data: privacyResponsesData),
            .init(data: returnedConfigData),
            .init(error: webViewResponseError) // broken webview request
        ]

        responses = [responses, brokenRetriedRequests].flatMap { $0 }

        let expectedNumberOfRequests = responses.count

        var sdkMetrics: [SDKMetricType] =  [
            .legacy(.initStarted),
            .legacy(.latency(.infoCollection)),
            .legacy(.latency(.infoCompression)),
            .legacy(.latency(.configRequestSuccess)),
            .legacy(.missed(.token)),
            .legacy(.missed(.stateID)),
            .legacy(.latency(.privacyRequestSuccess))

        ]

        let sdkPerformanceMetrics: [SDKMetricType] = [
            .taskPerformance(.success(.loadLocalConfig)),
            .taskPerformance(.success(.configFetch)),
            .taskPerformance(.success(.initModules)),
            .taskPerformance(.success(.reset)),
            .taskPerformance(.failure(.webViewDownload)),
            .taskPerformance(.failure(.initializer))
        ]

        sdkMetrics += sdkPerformanceMetrics

        let testConfig = TestConfig(responses: responses,
                                    sdkConfig: expectedConfig,
                                    expectedNumberOfRequests: expectedNumberOfRequests,
                                    multithreadCount: 1,
                                    metrics: sdkMetrics,
                                    webviewRetried: webViewRetries,
                                    expectDiagnostic: true)

        try executeTest(with: testConfig,
                        resultValidation: {
            XCTAssertFailure($0, expectedError: "Network error while loading WebApp from internet, waiting for connection")
        })
    }

    func test_init_fails_with_web_view_create_fails() throws {
        let returnedConfigData = try configMockFactory.defaultConfigData(experiments: defaultExperiments)
        let expectedConfig = try configMockFactory.defaultUnityAdsConfig(experiments: defaultExperiments)
        let privacyData = returnedConfigData
        let responses: [URLProtocolResponseStub] = [
            .init(data: privacyData),
            .init(data: returnedConfigData),
            .init(data: configMockFactory.webViewFakeData)
        ]

        var sdkMetrics: [SDKMetricType] =  [
            .legacy(.initStarted),
            .legacy(.latency(.infoCollection)),
            .legacy(.latency(.infoCompression)),
            .legacy(.latency(.configRequestSuccess)),
            .legacy(.missed(.token)),
            .legacy(.missed(.stateID)),
            .legacy(.latency(.privacyRequestSuccess))
        ]

        let sdkPerformanceMetrics: [SDKMetricType] = [
            .taskPerformance(.success(.loadLocalConfig)),
            .taskPerformance(.success(.configFetch)),
            .taskPerformance(.success(.initModules)),
            .taskPerformance(.success(.reset)),
            .taskPerformance(.success(.webViewDownload)),
            .taskPerformance(.failure(.webViewCreate)),
            .taskPerformance(.failure(.initializer))
        ]

        sdkMetrics += sdkPerformanceMetrics

        tester.initStateFactoryMock.webViewCreateError = MockedError()

        let testConfig = TestConfig(responses: responses,
                                    sdkConfig: expectedConfig,
                                    expectedNumberOfRequests: responses.count,
                                    multithreadCount: 1,
                                    metrics: sdkMetrics,
                                    expectDiagnostic: true)

        try  executeTest(with: testConfig,
                         resultValidation: {
            XCTAssertFailure($0, expectedError: "The operation couldn’t be completed. (UnityAdsTests.MockedError error 1.)")
        })
    }

    func test_init_succeed_no_web_view_download_when_the_same_in_cache() throws {
        let expectedNumberOfRequests = 2

        try tester.saveDefaultFakeWebViewDataToFile()

        let returnedConfigData = try configMockFactory.defaultConfigData(experiments: defaultExperiments)
        let expectedConfig = try configMockFactory.defaultUnityAdsConfig(experiments: defaultExperiments)
        let privacyData = returnedConfigData
        let responses: [URLProtocolResponseStub] = [
            .init(data: privacyData),
            .init(data: returnedConfigData),
            .init(data: configMockFactory.webViewFakeData)
        ]

        var sdkMetrics: [SDKMetricType] =  [
            .legacy(.initStarted),
            .legacy(.latency(.infoCollection)),
            .legacy(.latency(.infoCompression)),
            .legacy(.latency(.configRequestSuccess)),
            .legacy(.missed(.token)),
            .legacy(.missed(.stateID)),
            .legacy(.latency(.privacyRequestSuccess))
        ]

        let sdkPerformanceMetrics: [SDKMetricType] = [
            .taskPerformance(.success(.loadLocalConfig)),
            .taskPerformance(.success(.configFetch)),
            .taskPerformance(.success(.webViewDownload)),
            .taskPerformance(.success(.webViewCreate)),
            .taskPerformance(.success(.initModules)),
            .taskPerformance(.success(.reset)),
            .taskPerformance(.success(.complete)),
            .taskPerformance(.success(.initializer))
        ]

        sdkMetrics += sdkPerformanceMetrics

        let testConfig = TestConfig(responses: responses,
                                    sdkConfig: expectedConfig,
                                    expectedNumberOfRequests: expectedNumberOfRequests,
                                    multithreadCount: 1,
                                    metrics: sdkMetrics,
                                    expectDiagnostic: true)

        try executeTest(with: testConfig,
                        resultValidation: { XCTAssertSuccess($0) })

    }

    func test_multithread_should_not_crash_and_return_success() throws {
        let returnedConfigData = try configMockFactory.defaultConfigData(experiments: defaultExperiments)
        let expectedConfig = try configMockFactory.defaultUnityAdsConfig(experiments: defaultExperiments)
        let privacyData = returnedConfigData
        let responses: [URLProtocolResponseStub] = [
            .init(data: privacyData),
            .init(data: returnedConfigData),
            .init(data: configMockFactory.webViewFakeData)
        ]

        var sdkMetrics: [SDKMetricType] =  [
            .legacy(.initStarted),
            .legacy(.latency(.infoCollection)),
            .legacy(.latency(.infoCompression)),
            .legacy(.latency(.configRequestSuccess)),
            .legacy(.missed(.token)),
            .legacy(.missed(.stateID)),
            .legacy(.latency(.privacyRequestSuccess))
        ]

        let sdkPerformanceMetrics: [SDKMetricType] = [
            .taskPerformance(.success(.loadLocalConfig)),
            .taskPerformance(.success(.configFetch)),
            .taskPerformance(.success(.webViewDownload)),
            .taskPerformance(.success(.webViewCreate)),
            .taskPerformance(.success(.initModules)),
            .taskPerformance(.success(.reset)),
            .taskPerformance(.success(.complete)),
            .taskPerformance(.success(.initializer))
        ]

        sdkMetrics += sdkPerformanceMetrics

        let testConfig = TestConfig(responses: responses,
                                    sdkConfig: expectedConfig,
                                    expectedNumberOfRequests: responses.count,
                                    multithreadCount: stressCount,
                                    metrics: sdkMetrics,
                                    expectDiagnostic: true)

        try executeTest(with: testConfig,
                        resultValidation: { XCTAssertSuccess($0) })

    }

    func test_state_initialized_should_return_success_without_calling_infractructure() throws {
        tester.sdkState = .initialized
        let expectedConfig = try configMockFactory.defaultUnityAdsConfig(experiments: defaultExperiments)

        let testConfig = TestConfig(responses: [],
                                    sdkConfig: expectedConfig,
                                    expectedNumberOfRequests: 0,
                                    multithreadCount: stressCount,
                                    metrics: [],
                                    expectDiagnostic: true,
                                    validateStartTimeStamp: false)

        try executeTest(with: testConfig,
                        resultValidation: { XCTAssertSuccess($0) })

    }

    func test_state_failed_should_return_failed_without_calling_infractructure() throws {
        tester.sdkState = .failed(MockedError())
        let expectedConfig = try configMockFactory.defaultUnityAdsConfig(experiments: defaultExperiments)
        let testConfig = TestConfig(responses: [],
                                    sdkConfig: expectedConfig,
                                    expectedNumberOfRequests: 0,
                                    multithreadCount: stressCount,
                                    metrics: [],
                                    expectDiagnostic: true,
                                    validateStartTimeStamp: false)
        try executeTest(with: testConfig,
                        resultValidation: {
            XCTAssertFailure($0, expectedError: "The operation couldn’t be completed. (UnityAdsTests.MockedError error 1.)")
        })
    }

    func test_webview_download_skipped_when_native_webview_cache_is_on() throws {
        let expectedConfig = try configMockFactory.defaultUnityAdsConfig(experiments: defaultExperiments, currentExperiments: ["nwc": true])
        let returnedConfigData = try expectedConfig.legacy.convertIntoDictionary().serializedData()
        let privacyData = returnedConfigData
        let responses: [URLProtocolResponseStub] = [
            .init(data: privacyData),
            .init(data: returnedConfigData)
        ]

        let testConfig = TestConfig(responses: responses,
                                    sdkConfig: expectedConfig,
                                    expectedNumberOfRequests: responses.count,
                                    multithreadCount: 1,
                                    metrics: ExpectedMetrics.NewInitLegacyFlow.HappyPath,
                                    expectDiagnostic: true)
        try executeTest(with: testConfig,
                        resultValidation: { XCTAssertSuccess($0) },
                        final: {

            XCTAssertEqual(self.tester.sdkState, .initialized)
        })
    }
}

extension UnityAdsConfig: Equatable {
    public static func == (lhs: UnityAdsConfig, rhs: UnityAdsConfig) -> Bool {
        lhs.network == rhs.network && lhs.legacy.json.sortedDescription == rhs.legacy.json.sortedDescription
    }
}
