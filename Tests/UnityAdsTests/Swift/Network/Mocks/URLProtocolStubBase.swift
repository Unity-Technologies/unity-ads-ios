import Foundation
@testable import UnityAds

class URLProtocolStubBase: URLProtocol {
    static let queue = DispatchQueue(label: "URLProtocolStub.queue")
    class func clear() {
        updateResponseStubs([])
        updateReceivedRequests([])
    }

    func nextStub(for request: URLRequest) -> URLProtocolResponseStub? {
        Self.nextStub(for: request)
    }

    static func addExpectedStub(_ stub: URLProtocolResponseStub) {
        stubs = stubs.appended(stub)
    }

    static func setExpectedData(_ data: Data?, at index: Int = 0) {
        stubs.getSafely(at: index)
             .map({ $0.new(with: data) })
             .do({ stubs.insert($0, at: index) })
                 .onNone({ stubs.append(.init(data: data)) })
    }

    static func setExpectedError(_ error: Error?, at index: Int = 0) {
        stubs.getSafely(at: index)
             .map({ $0.new(with: error) })
             .do({ stubs.insert($0, at: index) })
             .onNone({ stubs.append(.init(error: error)) })
    }

    static func setExpectedStatus(_ status: Int, at index: Int = 0) {
        stubs.getSafely(at: index)
             .map({ $0.new(with: status) })
             .do({ stubs.insert($0, at: index) })
             .onNone({ stubs.append(.init()) })
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return false
    }

    override func startLoading() {
        let currentRequest = request

        appendRequest(currentRequest)
        beforeResponse()

        let stub = nextStub(for: currentRequest)
        if let expectedData = stub?.data {
            client?.urlProtocol(self, didLoad: expectedData)
        }

        if let response = urlResponse(for: stub, request: currentRequest) {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let expectedError = stub?.error {
            client?.urlProtocol(self, didFailWithError: expectedError)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    func beforeResponse() {

    }

    private func appendRequest(_ urlRequest: URLRequest) {
        Self.appendRequest(request)
    }

    class func appendRequest(_ urlRequest: URLRequest) {
        fatalError("Subclasses Must override")
    }

    class func receivedRequests() -> [URLRequest] {
        fatalError("Subclasses Must override")
    }

    class func updateReceivedRequests(_ requests: [URLRequest]) {
        fatalError("Subclasses Must override")
    }

    class func allResponseStubs() -> [URLProtocolResponseStub] {
        fatalError("Subclasses Must override")
    }

    class func updateResponseStubs(_ stubs: [URLProtocolResponseStub]) {
        fatalError("Subclasses Must override")
    }

    private func urlResponse(for stub: URLProtocolResponseStub?, request: URLRequest) -> HTTPURLResponse? {
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

extension URLProtocolStubBase {

}

extension URLProtocolStubBase {

    private static var stubs: [URLProtocolResponseStub] {
        get { queue.sync { allResponseStubs() } }
        set { queue.sync { updateResponseStubs(newValue) } }
    }

    private static func nextStub(for request: URLRequest) -> URLProtocolResponseStub? {
        return queue.sync {
            let removingResult = removeStub(for: request, stubs: allResponseStubs())
            updateResponseStubs(removingResult.stubs)
            return removingResult.stub
        }
    }

    private static func removeStub(for request: URLRequest,
                                   stubs: [URLProtocolResponseStub]) -> (stub: URLProtocolResponseStub?, stubs: [URLProtocolResponseStub]) {
        let stub: URLProtocolResponseStub?
        var stubs = stubs
        if let stubIndex = stubs.firstIndex(where: { $0.url == request.url?.absoluteString && $0.url != nil }) {
            stub = stubs.remove(at: stubIndex)
        } else if let index = stubs.firstIndex(where: { $0.url == nil }) {
            stub = stubs.remove(at: index)
        } else {
            stub = stubs.removedFirstSafely()
        }

        return (stub, stubs)
    }

    static var requests: [URLRequest] {
        get { return queue.sync { receivedRequests() } }
        set { queue.sync { updateReceivedRequests(newValue) } }
    }

    private static var _currentRequest: URLRequest?

    private static var currentRequest: URLRequest? {
        get { return queue.sync { _currentRequest } }
        set { queue.sync { _currentRequest = newValue } }
    }

    private var currentRequest: URLRequest? {
        Self.currentRequest
    }
}
