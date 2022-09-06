import XCTest
@testable import UnityAds

class UADSWebRequestSwiftAdapterTests: XCTestCase {
    override func setUp() {
        UADSURLProtocolStub.clear()

        let urlSessionConfiguration: URLSessionConfiguration = .ephemeral
        urlSessionConfiguration.protocolClasses = [UADSURLProtocolStub.self]
        ServiceProviderObjCBridge.shared.serviceProvider.mainSessionConfiguration = urlSessionConfiguration
    }

    override func tearDown() {
        UADSURLProtocolStub.clear()
    }

    func test_adapter_sends_correct_request() {
        setExpectedData(expectedData)
        setExpectedStatus(successCode)
        let headers = ["header1": ["value1", "value1.1"], "header2": ["value2"]]
        let expectedHeaders =  ["header1": "value1", "header2": "value2"]
        let request = UADSWebRequestFactorySwiftAdapter().create(testUrl, requestType: "GET", headers: headers, connectTimeout: Int32(timeout))

        let data = request?.make()
        XCTAssertEqual(expectedData, data)
        XCTAssertEqual(request?.receivedData as? Data, expectedData)
        XCTAssertEqual(request?.responseCode, successCode)
        XCTAssertNil(request?.error)

        let urlRequest = UADSURLProtocolStub.requests.first
        XCTAssertNotNil(urlRequest)
        XCTAssertEqual(urlRequest?.allHTTPHeaderFields, expectedHeaders)
        XCTAssertEqual(urlRequest?.timeoutInterval, timeout)
        XCTAssertEqual(urlRequest?.url, URL(string: testUrl))
    }

    func test_adapter_set_error_if_request_fails() {
        setExpectedError(NSError(domain: "UnityAds.HTTPURLResponseError", code: 100))
        let request = UADSWebRequestFactorySwiftAdapter().create(testUrl, requestType: "GET", headers: [:], connectTimeout: Int32(timeout))
        let data = request?.make()
        XCTAssertNotNil(request)
        XCTAssertNil(data)
        XCTAssertNil(request?.receivedData)
        XCTAssertNotNil(request?.error)
    }

    func setExpectedData(_ data: Data?) {
        UADSURLProtocolStub.setExpectedData(data)
    }

    func setExpectedError(_ error: Error?) {
        UADSURLProtocolStub.setExpectedError(error)
    }

    func setExpectedStatus(_ status: Int) {
        UADSURLProtocolStub.setExpectedStatus(status)
    }

    let expectedData = "expected data".data(using: .utf8)
    let successCode = 200
    let timeout: TimeInterval = 120
    let testUrl = "https://www.test.com/params?c=324jr4"
}
