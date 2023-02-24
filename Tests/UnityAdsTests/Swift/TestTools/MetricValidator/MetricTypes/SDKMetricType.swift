import Foundation
@testable import UnityAds

protocol DiagnosticMetricConvertible {
    var diagnosticMetric: UnityAdsDiagnosticMetric { get }
}

protocol LegacyMetricConvertible {
    var legacyMetric: UADSMetric { get }
}

enum SDKMetricType: DiagnosticMetricConvertible {
    case legacy(Legacy)
    case network(MetricsAdapter.NetworkMetric)
    case taskPerformance(Latency<Task>)
    case requestPerformance(Latency<Request>)
    case systemPerformance(Latency<System>)
    var diagnosticMetric: UnityAdsDiagnosticMetric {
        switch self {
        case .legacy(let legacy):
            return legacy.diagnosticMetric
        case .network(let networkMetricType):
            return networkMetricType.defaultDiagnosticMetric
        case .taskPerformance(let perf):
            return perf.defaultDiagnosticMetric(systemSuffix: "task")
        case .requestPerformance(let latency):
            return latency.defaultDiagnosticMetric()
        case .systemPerformance(let latency):
            return latency.defaultDiagnosticMetric()
        }
    }

}

extension SDKMetricType {
    enum Latency<T: PerformanceMeasurable> {
        case success(T)
        case failure(T)

        func defaultDiagnosticMetric(systemSuffix: String = "") -> UnityAdsDiagnosticMetric {
            let name: String
            let suffix = systemSuffix.isEmpty ? "" : "\(systemSuffix)_"
            switch self {

            case .success(let m):
                name = "\(m.systemName)_\(suffix)success"
            case .failure(let m):
                name = "\(m.systemName)_\(suffix)failure"
            }

            return .nativePrefixed(name: name + "_time", value: 0, tags: [:])
        }
    }
}

extension PerformanceMeasurable {
    var systemName: String {
        resultMetrics.SystemName
    }
}

extension SDKMetricType {
    enum Request: PerformanceMeasurable {
        var startEventName: String? { return nil }

        var resultMetrics: ResultMetrics.Type {
            switch self {
            case .privacy: return Constants.Metrics.PrivacyRequest.self
            case .config: return Constants.Metrics.ConfigRequest.self
            }
        }

        case privacy
        case config
    }

}

extension SDKMetricType {
    private typealias MetricsType = Constants.Metrics.Task
    enum Task: PerformanceMeasurable {
        var startEventName: String? { return nil }
        var resultMetrics: ResultMetrics.Type {
            switch self {
            case .reset:
                return MetricsType.Reset.self
            case .configFetch:
                return MetricsType.ConfigFetch.self
            case .privacyFetch:
                return MetricsType.PrivacyFetch.self
            case .webViewDownload:
                return MetricsType.WebViewDownload.self
            case .webViewCreate:
                return MetricsType.WebViewCreate.self
            case .loadLocalConfig:
                return MetricsType.LoadLocalConfig.self
            case .complete:
                return MetricsType.Complete.self
            case .initModules:
                return MetricsType.InitModules.self
            case .initializer: return MetricsType.Initializer.self
            }
        }
        case reset
        case configFetch
        case privacyFetch
        case webViewDownload
        case webViewCreate
        case loadLocalConfig
        case complete
        case initModules
        case initializer

    }
}

extension SDKMetricType {
    enum System: PerformanceMeasurable {
        var startEventName: String? { return nil }
        var resultMetrics: ResultMetrics.Type {
            switch self {
            case .compression: return Constants.Metrics.Compression.self
            }
        }
        case compression

    }

}

extension SDKMetricType.Latency {
}

extension MetricsAdapter.NetworkMetric {
    var defaultDiagnosticMetric: UnityAdsDiagnosticMetric {
        .nativePrefixed(name: self.name, value: self.value, tags: [:])
    }
}

extension InitTaskState: PerformanceMeasurable {
    public var startEventName: String? { Constants.Metrics.Task.Initializer.Started }
    public var resultMetrics: ResultMetrics.Type { metricsType }

}
