import Foundation
@testable import UnityAds

struct SDKConfigFactoryMock {
    var usrvConfigDictionary: [String: Any] {
        [
            "url": "https://webview.source.com",
            "hash": "acd7e5d675278e91cee63685d2f1e6693b26569b4cf28e390ef7cbc0adaa4602",
            "msr": 100,
            "ntwd": true,
            "murl": "https://metricURL.source.com",
            "net": 1,
            "wto": 1,
            "wct": 1,
            "rd": 1,
            "scf": 1,
            "SRR": "test"
        ]
    }

    var webViewFakeData: Data {
        "webViewFakeData".data(using: .utf8) ?? .init()
    }

    var webViewFakeDataPrivacy: Data {
        "webViewFakeDataFromPrivacy".data(using: .utf8) ?? .init()
    }
    var webViewFakeDataPrivacyHash: String {
        "a711a027fcc404981b18c68f625aeeda4d99bc03e30c0f6dc6a02f56fdfa02fd"
    }

    func defaultConfig(experiments: [String: Bool]) -> USRVConfiguration {
        return .new(fromJSON: defaultConfigJSON(experiments: experiments))
    }

    func defaultConfigData(experiments: [String: Bool]) throws -> Data {
        return try defaultConfigJSON(experiments: experiments).serializedData()
    }

    func defaultConfigJSON(experiments: [String: Bool]) -> [String: Any] {
        var dictionary = usrvConfigDictionary
        dictionary["expo"] = experiments.mapValues({ [ "value": $0 ] })
        return dictionary
    }

    func defaultUnityAdsConfig(experiments: [String: Bool]) throws -> UnityAdsConfig {
        guard let json = defaultConfig(experiments: experiments).originalJSON as? [String: Any] else {
            fatalError()
        }
        return UnityAdsConfig(from: try LegacySDKConfig(dictionary: json))
    }
}
