import Foundation
@testable import UnityAds

final class URLProtocolMainNetworkStub: URLProtocolStubBase {
    private static var _requests: [URLRequest] = []
    private static var _stubs: [URLProtocolResponseStub] = []

    override class func appendRequest(_ urlRequest: URLRequest) {
        _requests = _requests.appended(urlRequest)
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
}
