import Foundation

enum ExecutionCategory<T> {
    case sync(T)
    case async([T])
}

extension ExecutionCategory: Equatable where T: Equatable {}

typealias InitTaskCategory = ExecutionCategory<InitTaskState>

enum InitTaskState {
    case reset
    case configFetch
    case privacyFetch
    case webViewDownload
    case webViewCreate
    case loadLocalConfig
    case complete
    case initModules

}

extension InitTaskState {
    var legacyType: USRVInitializeStateType {
        switch self {
        case .reset:
            return .reset
        case .configFetch:
            return .configFetch
        case .webViewDownload:
            return .loadWebView
        case .webViewCreate:
            return .createWebView
        case .loadLocalConfig:
            return .configLocal
        case .complete:
            return .complete
        case .initModules:
            return .initModules
        case .privacyFetch:
            fatalError("Legacy doesnt have \(self) implementation")
        }
    }

    var metricsType: ResultMetrics.Type {
        typealias MetricsType = Constants.Metrics.Task
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
        }
    }

}
