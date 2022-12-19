import XCTest
@testable import UnityAds

class UnityAdsNetworkLayerTestCase: NetworkTestCaseBase {
    typealias NetworkResult = UnityAdsWebViewNetwork.Result<UnityAdsWebViewNetwork.Response>
    typealias ResultCompletion = Closure<NetworkResult>
    var serviceProvider: UnityAdsServiceProvider {
        networkTester.serviceProvider
    }

    var sut: UnityAdsWebViewNetwork {
        return serviceProvider.unityAdsWebViewNetwork
    }

    func test_successfully_decodes_object_into_a_type_erased_dictionary() throws {
        let obj = MockedResponseObject()
        let expectedResponse = String(data: try obj.serializedData(), encoding: .utf8) ?? ""
        let requestDictionary = URLConvertibleMockFactory.fullRequestDictionary
        try execute(request: requestDictionary, expectedData: obj) { result in

            let receivedResult = result.map({ $0.response })
            let receivedStatus = result.map({ $0.responseCode })

            XCTAssertEqualResult(receivedResult, .success(expectedResponse))
            XCTAssertEqualResult(receivedStatus, .success(200))
        }
    }

    func test_successfully_converts_dictionary_to_request() throws {

        try execute(request: correctRequestDictionary) { result in
            XCTAssertEqualResult(result.map({ $0.url }), .success(self.expectedURLString))
        }
    }

    func test_empty_dictionary_returns_error() throws {
        try execute(request: [:]) { result in
            XCTAssertFailure(result)
        }
    }

    func test_successfully_converts_response_into_a_dictionary() throws {
        let obj = MockedResponseObject()
        let data = try obj.serializedData()
        let requestDictionary = URLConvertibleMockFactory.fullRequestDictionary
        networkTester.addExpectedMainResponseStub(.init(data: data))

        let exp = defaultExpectation
        self.sut.sendAndDecode(using: requestDictionary) { result in
            XCTAssertSuccess(result.flatMap({ convertToObject($0) }))
            exp.fulfill()
        }

        wait(for: [exp], timeout: waitingTimeout)

    }

    func test_contains_metric_object_in_response() throws {
        try execute(request: correctRequestDictionary) { result in
            result.do({ XCTAssertNotNil($0.metrics) })
                  .onFailure({ _ in  XCTFail("Result is expected to be success") })
        }
    }

    func test_calls_metrics_if_url_is_in_the_config() throws {
        let metricsUrl = "//metricsURL"

        let metricsExpectation = verifyMetricsRequest { request in
            XCTAssertEqual(request.url?.absoluteString, metricsUrl)
        }

        try execute(request: correctRequestDictionary) { result in
            XCTAssertSuccess(result)
        }

        serviceProvider.sdkStateStorage.config = config(with: metricsUrl, enabled: true, networkDiagnosticEnabled: true)
        serviceProvider.sdkStateStorage.notifyObservers(with: VoidSuccess)

        wait(for: [metricsExpectation], timeout: waitingTimeout)
    }

    func test_doesnt_call_metric_sender_when_disabled() throws {
        let metricsUrl = "//metricsURL"
        serviceProvider.sdkStateStorage.config = config(with: metricsUrl, enabled: true, networkDiagnosticEnabled: false)

        let metricsExpectation = verifyMetricsRequest { _ in }
        metricsExpectation.isInverted = true

        try execute(request: correctRequestDictionary) { _ in }

        wait(for: [metricsExpectation], timeout: waitingTimeout)
    }

    func test_doesnt_send_metrics_when_url_is_empty() throws {

        serviceProvider.sdkStateStorage.config = config(with: "", enabled: true, networkDiagnosticEnabled: true)

        let metricsExpectation = verifyMetricsRequest { _ in }
        metricsExpectation.isInverted = true

        try execute(request: correctRequestDictionary) { _ in }

        wait(for: [metricsExpectation], timeout: waitingTimeout)
    }

    func test_returns_expected_error() throws {
        let requestDictionary = URLConvertibleMockFactory.fullRequestDictionary
        let expectedError = MockedDefaultError()
        try execute(request: requestDictionary, expectedError: expectedError) { result in
            XCTAssertFailure(result)
        }
    }

    func execute(request: [String: Any],
                 expectedData: MockedResponseObject? = nil,
                 expectedError: Error? = nil,
                 statusCode: Int = 200,
                 completion: @escaping ResultCompletion,
                 file: StaticString = #filePath,
                 line: UInt = #line) throws {
        let stub = URLProtocolResponseStub(data: try expectedData?.serializedData(),
                                           status: statusCode,
                                           error: expectedError)
        networkTester.addExpectedMainResponseStub(stub)

        let exp = defaultExpectation
        let sut = makeSut(file: file, line: line)
        sut.sendRequest(using: request) { result in
            completion(result)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 30)

    }

    private func makeSut(file: StaticString = #filePath, line: UInt = #line) -> UnityAdsWebViewNetwork {
        let sut = serviceProvider.unityAdsWebViewNetwork
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }

    var metricsRequests: [URLRequest] {
        networkTester.metricsRequests
    }

    func config(with metricsURL: String, enabled: Bool, networkDiagnosticEnabled: Bool) -> UnityAdsConfig {
        let metrics: UnityAdsConfig.Network.Metrics = .init(url: metricsURL,
                                                            batchSize: 0,
                                                            enabled: enabled,
                                                            networkDiagnosticEnabled: networkDiagnosticEnabled)
        let webView: UnityAdsConfig.Network.WebView = .init(url: "url", hash: "hash", retry: .default)
        let network: UnityAdsConfig.Network = .init(metrics: metrics,
                                                    webView: webView,
                                                    request: .default)
        return .init(network: network, legacy: .default)
    }
}

private func convertToObject(_ dictionary: [String: Any]) -> Result<UnityAdsWebViewNetwork.Response, UnityAdsWebViewNetwork.RequestError> {
    do {
        return .success(try .init(dictionary: dictionary))
    } catch {
        return .failure(UnityAdsWebViewNetwork.RequestError(error: error, dictionary: dictionary))
    }
}
