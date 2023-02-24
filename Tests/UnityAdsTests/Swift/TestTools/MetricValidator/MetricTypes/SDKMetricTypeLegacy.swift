import Foundation
@testable import UnityAds

extension SDKMetricType {
    enum Legacy: DiagnosticMetricConvertible {
        case missed(MissedCategory)
        case latency(Latency)
        case performance(State)
        case initStarted
        case initializationCompleted
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

    enum State {
        case reset
        case config
        case webViewDownload
        case webViewCreate
        case loadLocalConfig
        case loadCache
        case complete
        case initModules
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
        case .performance(let state):
            return state.legacyMetric
        case .initializationCompleted:
            return UADSTsiMetric.newInitTimeSuccess(0, tags: [:])
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

extension SDKMetricType.Legacy.State: LegacyMetricConvertible {
    var legacyMetric: UADSMetric {
        let state: USRVInitializeState
        switch self {

        case .reset:
            state = USRVInitializeStateReset()
        case .config:
            state = USRVInitializeStateConfig()
        case .webViewDownload:
            state = USRVInitializeStateLoadWeb()
        case .webViewCreate:
            state = USRVInitializeStateCreate()
        case .loadLocalConfig:
            state = USRVInitializeStateLoadConfigFile()
        case .complete:
            state = USRVInitializeStateComplete()
        case .initModules:
            state = USRVInitializeStateInitModules()
        case .loadCache:
            state = USRVInitializeStateLoadCache()
        }

        return .new(withName: state.metricName(), value: nil, tags: nil)
    }

}
