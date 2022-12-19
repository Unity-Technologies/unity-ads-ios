import Foundation
@testable import UnityAds

extension SDKMetricType {
    enum Legacy: DiagnosticMetricConvertible {
        case missed(MissedCategory)
        case latency(Latency)
        case switchOff
        case initStarted
        case nativeTokenNull
        case nativeTokenAvailable
        case asyncTokenNull
        case asyncTokenAvailable
        var diagnosticMetric: UnityAdsDiagnosticMetric { legacyMetric.diagnosticMetric }
    }

}

extension SDKMetricType.Legacy {
    enum MissedCategory {
        case token
        case stateID
    }

    enum Latency {
        case initSuccess
        case initFailure
        case webToken
        case configToken
        case configRequestSuccess
        case privacyRequestSuccess
        case configRequestFailure
        case intoCollection
        case infoCompression
    }
}

extension SDKMetricType.Legacy: LegacyMetricConvertible {
    var legacyMetric: UADSMetric {
        switch self {
        case .missed(let missed):
            return missed.legacyMetric
        case .latency(let latency):
            return latency.legacyMetric
        case .initStarted:
            return UADSTsiMetric.newInitStarted()
        case .nativeTokenNull:
            return UADSTsiMetric.newNativeGeneratedTokenNull(withTags: [:])
        case .nativeTokenAvailable:
            return UADSTsiMetric.newNativeGeneratedTokenAvailable(withTags: [:])
        case .asyncTokenNull:
            return UADSTsiMetric.newAsyncTokenNull(withTags: [:])
        case .asyncTokenAvailable:
            return UADSTsiMetric.newAsyncTokenTokenAvailable(withTags: [:])
        case .switchOff:
            return UADSTsiMetric.newEmergencySwitchOff()
        }
    }
}

extension SDKMetricType.Legacy.MissedCategory: LegacyMetricConvertible {
    var legacyMetric: UADSMetric {
        switch self {
        case .token:
            return UADSTsiMetric.newMissingToken()
        case .stateID:
            return UADSTsiMetric.newMissingStateId()
        }
    }
}

extension SDKMetricType.Legacy.Latency: LegacyMetricConvertible {
    var legacyMetric: UADSMetric {
        switch self {

        case .initSuccess:
            return UADSTsiMetric.newInitTimeSuccess(nil, tags: [:])
        case .initFailure:
            return UADSTsiMetric.newInitTimeFailure(nil, tags: [:])
        case .webToken:
            return UADSTsiMetric.newInitTimeFailure(nil, tags: [:])
        case .configToken:
            return UADSTsiMetric.newTokenAvailabilityLatencyConfig(nil, tags: [:])
        case .configRequestSuccess:
            return UADSTsiMetric.newTokenResolutionRequestLatency(nil, tags: [:])
        case .configRequestFailure:
            return UADSTsiMetric.newTokenResolutionRequestFailureLatency([:])
        case .intoCollection:
            return UADSTsiMetric.newDeviceInfoCollectionLatency(0)
        case .infoCompression:
            return UADSTsiMetric.newDeviceInfoCompressionLatency(0)
        case .privacyRequestSuccess:
            return UADSPrivacyMetrics.newPrivacyRequestSuccessLatency([:])
        }
    }
}
