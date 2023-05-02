import Foundation
@testable import UnityAds

final class URLProtocolMetricsNetworkStub: URLProtocolStubBase {

    @Atomic static var requestObserver: Closure<URLRequest>?

    private static var _requests: [URLRequest] = []
    private static var _stubs: [URLProtocolResponseStub] = []

    override class func clear() {
        super.clear()
        _requestObserver.mutate({ $0 = nil })
    }

    override class func appendRequest(_ urlRequest: URLRequest) {
        _requests = _requests.appended(urlRequest)
    }

    override func nextStub(for request: URLRequest) -> URLProtocolResponseStub? {
        .init(data: nil, status: 200, error: nil)
    }

    override class func receivedRequests() -> [URLRequest] {
        _requests
    }

    override class func updateReceivedRequests(_ requests: [URLRequest]) {
        _requests = requests
    }

    override class func allResponseStubs() -> [URLProtocolResponseStub] {
        _stubs
    }

    override class func updateResponseStubs(_ stubs: [URLProtocolResponseStub]) {
        _stubs = stubs
    }

    override func beforeResponse() {
        Self._requestObserver.load()?(request)
    }
}
