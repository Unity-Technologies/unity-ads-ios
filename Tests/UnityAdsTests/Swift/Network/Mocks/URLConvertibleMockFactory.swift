import Foundation
@testable import UnityAds

struct URLConvertibleMockFactory {

    static var fakeRequest: UnityAdsNetworkRequest {
        .init(id: "ID", baseURL: expectedFullBaseURLString)
    }

    static var fullRequestDictionary: [String: Any] {
        [
            "baseURL": "baseURL.com",
            "path": "/path",
            "parameters": [
                "id": "id"
            ],
            "headers": [
                "header1": "header1"
            ],
            "port": 980,
            "scheme": "https",
            "method": "GET",
            "id": "ID"
        ]
    }

    static var expectedFullBaseURLString: String {
        "https://baseURL.com:980/path?id=id"
    }

    static var urlOnlyRequestDictionary: [String: Any] {
        [
            "baseURL": expectedFullBaseURLString,
            "id": "ID"
        ]
    }

    static var emptyRequestDictionary: [String: Any] {
        [:]
    }

    static var mockCustomRequest: MockRequest {
        .init()
    }

    static func mockUnityAdsRequest() throws -> UnityAdsNetworkRequest {
        try UnityAdsNetworkRequest(dictionary: fullRequestDictionary)
    }
}

extension URLConvertibleMockFactory {
    struct MockRequest: URLRequestConvertible {
        var baseURL: String =   "www.myApi.com"
        var path: String = "/console"
        var parameters: [String: String] =
             ["role": "admin", "access": "full"]

        var headers: [String: String] = ["username": "admin", "password": "12345"]

        var body: Data? =  {
            guard let data = "Test".data(using: .utf8) else {
                fatalError()
            }
            return data
        }()

        var method: String =  "GET"
        var scheme: String? = "https"
        var port: Int? = 980
        var requestTimeout: TimeInterval? = 60
        var id: String = "ID"
        static var expectedURLString: String {
            "https://www.myApi.com:980/console"
        }
    }
}

extension URLConvertibleMockFactory {
    static var networkMetricsMock: NetworkTaskMetrics {
        var metrics = NetworkTaskMetrics()
        metrics.transactionMetrics = [networkTransactionMetricMock]
        metrics.taskInterval = 5
        metrics.redirectCount = 0
        return metrics
    }

    static var networkTransactionMetricMock: NetworkTaskMetrics.TransactionMetrics {
        var transactionMetrics = NetworkTaskMetrics.TransactionMetrics()

        transactionMetrics.connectStartDate = 0
        transactionMetrics.connectEndDate = 2

        transactionMetrics.responseStartDate = 0
        transactionMetrics.responseEndDate = 3

        transactionMetrics.requestStartDate = 0
        transactionMetrics.requestEndDate = 4

        transactionMetrics.secureConnectionStartDate = 0
        transactionMetrics.secureConnectionEndDate = 5

        transactionMetrics.domainLookupStartDate = 0
        transactionMetrics.domainLookupEndDate = 6
        return transactionMetrics
    }
}
