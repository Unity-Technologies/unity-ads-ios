import Foundation
import CryptoKit

@testable import UnityAds

struct SDKConfigFactoryMock {
    let useConfigExample: Bool
    var usrvConfigDictionary: [String: Any] {
        useConfigExample ? configFromFile : simpleMockDictionary

    }

    var simpleMockDictionary: [String: Any] {
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

    var configFromFile: [String: Any ] {
        var mock = JSONResources.configResponse
        mock["url"] = "https://webview.source.com"
        mock["hash"] = "acd7e5d675278e91cee63685d2f1e6693b26569b4cf28e390ef7cbc0adaa4602"
        mock["msr"] = 100
        mock["ntwd"] = true
        mock["murl"] = "https://metricURL.source.com"
        mock["net"] = 1
        mock["wto"] = 1
        mock["wct"] = 1
        mock["rd"] = 1
        mock["scf"] = 1
        return mock
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

    var longWebViewDataString: String {
        let sizeInMb = 5
        return String(repeating: "*", count: 1_024*1_024*sizeInMb)
    }

    @available(iOS 13.0, *)
    var longWebViewDataDataHash: String {
       return SHA256.hash(data: longWebViewData).hexStr
    }

    var longWebViewData: Data {
        guard let data = longWebViewDataString.data(using: .utf8) else {
            fatalError()
        }

        return data
    }

    func defaultConfig(experiments: [String: Any],
                       currentExperiments: [String: Any] = [:],
                       overrideJSON: [String: Any] = [:]) -> USRVConfiguration {
        return .new(fromJSON: defaultConfigJSON(experiments: experiments, currentExperiments: currentExperiments, overrideJSON: overrideJSON))
    }

    func defaultConfigData(experiments: [String: Any],
                           currentExperiments: [String: Any] = [:],
                           overrideJSON: [String: Any] = [:]) throws -> Data {
        return try defaultConfigJSON(experiments: experiments, currentExperiments: currentExperiments, overrideJSON: overrideJSON).serializedData()
    }

    func defaultConfigJSON(experiments: [String: Any],
                           currentExperiments: [String: Any] = [:],
                           overrideJSON: [String: Any] = [:]) -> [String: Any] {
        var dictionary = usrvConfigDictionary
        let currentExpo = currentExperiments.mapValues { ["value": $0, "applied": "current"] }
        var expo = experiments.mapValues({ [ "value": $0 ] })
        expo.merge(currentExpo) { _, s in s }
        dictionary["expo"] = expo
        return dictionary.merging(overrideJSON, uniquingKeysWith: { _, s in s })
    }

    func defaultUnityAdsConfig(experiments: [String: Any],
                               currentExperiments: [String: Any] = [:],
                               overrideJSON: [String: Any] = [:]) throws -> UnityAdsConfig {
        guard let json = defaultConfig(experiments: experiments,
                                       currentExperiments: currentExperiments,
                                       overrideJSON: overrideJSON).originalJSON as? [String: Any] else {
            fatalError()
        }
        return UnityAdsConfig(from: try LegacySDKConfig(dictionary: json))
    }

    func saveConfigToFile(_ config: UnityAdsConfig) throws {

        let path = FilePaths()
        try FileManager().save(obj: config.legacy, toFile: path.configURL)

    }
}

@available(iOS 13.0, *)
private extension Digest {
    var bytes: [UInt8] { Array(makeIterator()) }
    var data: Data { Data(bytes) }

    var hexStr: String {
        bytes.map { String(format: "%02hhx", $0) }.joined()
    }
}
