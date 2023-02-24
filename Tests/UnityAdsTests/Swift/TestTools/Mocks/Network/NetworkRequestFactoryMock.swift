import Foundation
@testable import UnityAds

final class NetworkRequestFactoryMock: NetworkRequestFactory {
    typealias RequestType = Request
    var expectedRequest: URLRequestConvertible = UnityAdsNetworkRequest(baseURL: "")
    var errorToThrow: Error?
    func createRequest(of type: RequestType) throws -> URLRequestConvertible {
        if let error = errorToThrow {
            throw error
        }

        return expectedRequest
    }
}

extension NetworkRequestFactoryMock {
    enum Request {
        case mockRequest
    }
}
