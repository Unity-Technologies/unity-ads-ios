import Foundation
@testable import UnityAds
import XCTest

final class WebRequestFactoryMock: NSObject, IUSRVWebRequestFactory, IUSRVWebRequestFactoryStatic {
    private let allowReturningEmptyData: Bool
    private let urlSession: URLSession

    init(allowReturningEmptyData: Bool = false,
         urlSession: URLSession) {
        self.allowReturningEmptyData = allowReturningEmptyData
        self.urlSession = urlSession
    }
    func create(_ url: String!,
                requestType: String!,
                headers: [String: [String]]!,
                connectTimeout: Int32) -> USRVWebRequest! {

        let request = MockWebRequest(url: url,
                                     requestType: requestType,
                                     headers: headers,
                                     connectTimeout: connectTimeout)
        request?.allowReturningEmptyData = allowReturningEmptyData
        request?.urlSession = urlSession
        return request
    }

    static func create(_ url: String!,
                       requestType: String!,
                       headers: [String: [String]]!,
                       connectTimeout: Int32) -> USRVWebRequest! {
        fatalError()
    }

}
