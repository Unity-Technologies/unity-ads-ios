import XCTest
@testable import UnityAds

class UADSWebRequestSwiftAdapterTests: XCTestCase {

    var objServiceProvider: ServiceProviderObjCBridge {
        networkTester.objServiceProvider
    }
    var networkTester = SDKNetworkTestsHelper()
    override func setUp() {
        networkTester = .init()
    }

    override func tearDownWithError() throws {
        networkTester.resetStubs()
    }

    var sut: UADSWebRequestFactorySwiftAdapter {
        let networkProxy = UADSCommonNetworkProxy(proxyObject: networkTester.objServiceProvider.nativeNetworkLayer)
        return .new(withMetricSender: nil,
                    andNetworkLayer: networkProxy)
    }

    var headers: [String: [String]] {
        ["header1": ["value1", "value1.1"], "header2": ["value2"]]
    }

    var expectedHeaders: [String: String] {
        ["header1": "value1", "header2": "value2"]
    }

    func executeWithSuccess(type: String,
                            body: String? = nil,
                            bodyData: Data? = nil,
                            file: StaticString = #filePath,
                            line: UInt = #line) {
        let stub: URLProtocolResponseStub = .init(data: expectedData, status: successCode, error: nil)
        networkTester.addExpectedMainResponseStub(stub)
        let request = sut.create(testUrl, requestType: type, headers: headers, connectTimeout: Int32(timeout))
        request?.body = body
        request?.bodyData = bodyData

        let data = request?.make()

        XCTAssertEqual(expectedData, data)
        XCTAssertEqual(request?.receivedData as? Data, expectedData)
        XCTAssertEqual(request?.responseCode, successCode)
        XCTAssertNil(request?.error)
        XCTAssertEqual(request?.requestType, type)

        let urlRequest = networkTester.networkRequests.first
        XCTAssertNotNil(urlRequest)
        var expectedHeaders = expectedHeaders
        if let data = bodyData ?? body?.data(using: .utf8) {
            expectedHeaders["Content-Length"] = "\(data.count)"
        }
        XCTAssertEqual(urlRequest?.allHTTPHeaderFields, expectedHeaders)
        XCTAssertEqual(urlRequest?.timeoutInterval, timeout / 1_000) // in seconds
        XCTAssertEqual(urlRequest?.url, URL(string: testUrl))

        if body != nil || bodyData != nil {
            XCTAssertNotNil(urlRequest?.httpBodyStream)
        } else {
            XCTAssertNil(urlRequest?.httpBodyStream)
        }
    }

    func createRequest(type: String, body: String? = nil, bodyData: Data? = nil) -> USRVWebRequest? {
        let request = sut.create(testUrl, requestType: "GET", headers: headers, connectTimeout: Int32(timeout))
        request?.body = body
        request?.bodyData = bodyData
        return request
    }

    func test_adapter_sends_correct_request() {
        executeWithSuccess(type: "GET")
    }

    func test_adapter_sends_correct_post_request_with_string_body() {
       executeWithSuccess(type: "POST", body: "test")
    }

    func test_adapter_sends_correct_post_request_with_data_body() {
        executeWithSuccess(type: "POST", bodyData: "test".data(using: .utf8))
    }

    func test_adapter_set_error_if_request_fails() {
        setExpectedError(NSError(domain: "UnityAds.HTTPURLResponseError", code: 100))
        let request = createRequest(type: "GET")
        let data = request?.make()
        XCTAssertNotNil(request)
        XCTAssertNil(data)
        XCTAssertNil(request?.receivedData)
        XCTAssertNotNil(request?.error)
    }

    func setExpectedData(_ data: Data?) {
        networkTester.setMetricsResponseExpectedData(data, at: 0)
    }

    func setExpectedError(_ error: Error?) {
        networkTester.setMetricsResponseExpectedError(error, at: 0)
    }

    func setExpectedStatus(_ status: Int) {
        networkTester.setMetricsResponseExpectedStatus(200, at: 0)
    }

    let expectedData = "expected data".data(using: .utf8)
    let successCode = 200
    let timeout: TimeInterval = 20_000 // obj-c requests in ms
    let testUrl = "https://www.test.com/params?c=324jr4"
}
