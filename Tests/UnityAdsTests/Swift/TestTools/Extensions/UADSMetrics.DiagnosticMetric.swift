import Foundation
@testable import UnityAds

extension UnityAdsDiagnosticMetric: DictionaryMappable {
    static var empty: Self {
        .init(name: "", value: nil, tags: [:])
    }
}

extension UADSMetric {

    var diagnosticMetric: UnityAdsDiagnosticMetric {
        guard let dictionary = dictionary() as? [String: Any] else {
            return .empty
        }

        let metric = try? UnityAdsDiagnosticMetric(dictionary: dictionary)
        return metric ?? .empty
    }

}
