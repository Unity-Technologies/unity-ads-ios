import Foundation

struct ExpectedMetrics {
}

extension ExpectedMetrics {
    struct LegacyFlow {
        static var HappyPath: [SDKMetricType] {
            var sdkMetrics: [SDKMetricType] =  [
                .legacy(.initStarted),
                .legacy(.latency(.intoCollection)),
                .legacy(.latency(.infoCompression)),
                .legacy(.missed(.token)),
                .legacy(.missed(.stateID)),
                .legacy(.latency(.privacyRequestSuccess)),
                .legacy(.latency(.configRequestSuccess)),
                .legacy(.performance(.complete)),
                .legacy(.performance(.initModules)),
                .legacy(.performance(.reset)),
                .legacy(.performance(.webViewDownload)),
                .legacy(.performance(.webViewCreate)),
                .legacy(.performance(.loadLocalConfig)),
                .legacy(.performance(.loadCache)),
                .legacy(.performance(.config)),
                .legacy(.initializationCompleted)
            ]
            return sdkMetrics
        }
    }
}

extension ExpectedMetrics {
    struct NewInitLegacyFlow {
        static var HappyPath: [SDKMetricType] {
            var sdkMetrics: [SDKMetricType] =  [
                .legacy(.initStarted),
                .legacy(.latency(.intoCollection)),
                .legacy(.latency(.infoCompression)),
                .legacy(.missed(.token)),
                .legacy(.missed(.stateID)),
                .legacy(.latency(.privacyRequestSuccess)),
                .legacy(.latency(.configRequestSuccess))
            ]

            let sdkPerformanceMetrics: [SDKMetricType] = [
                .taskPerformance(.success(.loadLocalConfig)),
                .taskPerformance(.success(.initializer)),
                .taskPerformance(.success(.configFetch)),
                .taskPerformance(.success(.webViewDownload)),
                .taskPerformance(.success(.webViewCreate)),
                .taskPerformance(.success(.initModules)),
                .taskPerformance(.success(.reset)),
                .taskPerformance(.success(.complete))
            ]

            sdkMetrics += sdkPerformanceMetrics
            return sdkMetrics
        }
    }
}

extension ExpectedMetrics {
    struct SequentialFlow {
        static var HappyPath: [SDKMetricType] {
            var sdkMetrics: [SDKMetricType] =  [
                .legacy(.initStarted),
                .legacy(.latency(.intoCollection)),
                .legacy(.missed(.token)),
                .legacy(.missed(.stateID))
            ]

            let sdkPerformanceMetrics: [SDKMetricType] = [
                .systemPerformance(.success(.compression)),
                .requestPerformance(.success(.privacy)),
                .requestPerformance(.success(.config)),
                .taskPerformance(.success(.loadLocalConfig)),
                .taskPerformance(.success(.privacyFetch)),
                .taskPerformance(.success(.configFetch)),
                .taskPerformance(.success(.webViewDownload)),
                .taskPerformance(.success(.webViewCreate)),
                .taskPerformance(.success(.initModules)),
                .taskPerformance(.success(.reset)),
                .taskPerformance(.success(.complete)),
                .taskPerformance(.success(.initializer))
            ]

            sdkMetrics += sdkPerformanceMetrics
            return sdkMetrics
        }

    }
}

extension ExpectedMetrics {
    struct ParallelFlow {
        static var HappyPath: [SDKMetricType] {
            var sdkMetrics: [SDKMetricType] =  [
                .legacy(.initStarted),
                .legacy(.latency(.intoCollection)),
                .legacy(.missed(.token)),
                .legacy(.missed(.stateID))
            ]

            let sdkPerformanceMetrics: [SDKMetricType] = [
                .systemPerformance(.success(.compression)),
                .requestPerformance(.success(.privacy)),
                .requestPerformance(.success(.config)),
                .taskPerformance(.success(.loadLocalConfig)),
                .taskPerformance(.success(.privacyFetch)),
                .taskPerformance(.success(.configFetch)),
                .taskPerformance(.success(.webViewDownload)),
                .taskPerformance(.success(.webViewCreate)),
                .taskPerformance(.success(.initModules)),
                .taskPerformance(.success(.reset)),
                .taskPerformance(.success(.complete)),
                .taskPerformance(.success(.initializer))
            ]

            sdkMetrics += sdkPerformanceMetrics
            return sdkMetrics
        }
    }
}
