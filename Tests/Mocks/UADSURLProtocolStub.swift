import Foundation

class UADSURLProtocolStub: URLProtocol {

    private struct Stub {
        var data: Data?
        var status: Int = 200
        var error: Error?

        func new(with data: Data?) -> Self {
            .init(data: data, status: status, error: error)
        }

        func new(with status: Int) -> Self {
            .init(data: data, status: status, error: error)
        }

        func new(with error: Error?) -> Self {
            .init(data: data, status: status, error: error)
        }
    }

    private static var _stub: Stub?
    private static var stub: Stub? {
        get { return queue.sync { _stub } }
        set { queue.sync { _stub = newValue } }
    }

    private var stub: Stub? {
        Self.stub
    }

    static let queue = DispatchQueue(label: "URLProtocolStub.queue")

    static var requests: [URLRequest] = []

    class func clear() {
        stub = nil
        requests = []
    }

    static func setExpectedData(_ data: Data?) {
        stub = stub?.new(with: data) ?? Stub(data: data)
    }

    static func setExpectedError(_ error: Error?) {
        stub = stub?.new(with: error) ?? Stub(error: error)
    }

    static func setExpectedStatus(_ status: Int) {
        stub = stub?.new(with: status) ?? Stub()
    }

    override class func canInit(with request: URLRequest) -> Bool {
        requests.append(request)
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {

        if let expectedData = stub?.data {
            client?.urlProtocol(self, didLoad: expectedData)
        }

        if let response = urlResponse {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let expectedError = stub?.error {
            client?.urlProtocol(self, didFailWithError: expectedError)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    var urlResponse: HTTPURLResponse? {
        HTTPURLResponse(url: request.url ?? defaultURLToCrashTests,
                        statusCode: stub?.status ?? 0,
                        httpVersion: "1.0",
                        headerFields: [:])
    }
    var defaultURLToCrashTests: URL {
        URL(fileURLWithPath: "it will crash the tests deliberately")
    }

    override func stopLoading() {}
}
