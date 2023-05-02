import XCTest
@testable import UnityAds

class NetworkTestCaseBase: XCTestCase {
    typealias ResultCompletion<T> = ResultClosure<GenericNetworkResponse<T>>

    var builder: NetworkSenderBuilder {
        NetworkSenderBuilder(urlSession: urlSession,
                             metricsReader: metricsCollector,
                             metricsSender: metricsSender,
                             allowedSuccessCodes: codes)
    }
    var urlSession: URLSession {
        .init(configuration: urlSessionConfiguration,
              delegate: metricsCollector,
              delegateQueue: nil)
    }

    var metricsCollector: URLSessionTaskMetricCollector?
    var metricsSender: MetricSender?
    var urlSessionConfiguration: URLSessionConfiguration = .default
    var metricsSessionConfiguration: URLSessionConfiguration = .default
    var codes: [Int] = []
    var expectationDescription: String { "\(self)" }
    var networkTester = SDKNetworkTestsHelper(useExampleConfig: false)
    var requestFactory: URLConvertibleMockFactory.Type {
        URLConvertibleMockFactory.self
    }

    var fakeRequest: UnityAdsNetworkRequest {
        requestFactory.fakeRequest
    }

    var expectedURLString: String {
        requestFactory.expectedFullBaseURLString
    }

    var correctRequestDictionary: [String: Any] {
        requestFactory.fullRequestDictionary
    }

    var urlOnlyRequestDictionary: [String: Any] {
        requestFactory.urlOnlyRequestDictionary
    }
    var waitingTimeout: TimeInterval = 1

    override func setUpWithError() throws {
        networkTester = .init(useExampleConfig: false)
        setUpNetworkProtocolStub()
    }

    func setUpNetworkProtocolStub() {
        codes = []
        metricsCollector = nil
        metricsSender = nil
        urlSessionConfiguration = networkTester.urlSessionConfiguration
        metricsSessionConfiguration = networkTester.metricURLSessionConfiguration
    }

    func verifyMetricsRequest(observer: @escaping Closure<URLRequest>) -> XCTestExpectation {
        let expectation = expectation(description: "\(self)-Metrics")
        let requestObserver: Closure<URLRequest> = { request in
            observer(request)
            expectation.fulfill()
        }
        networkTester.metricProtocolStub.$requestObserver.setNewValue(requestObserver)

        return expectation
    }

}

struct MockedError: Error, Equatable {

}
