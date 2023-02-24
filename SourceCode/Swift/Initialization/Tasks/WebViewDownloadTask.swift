import Foundation

final class WebViewDownloadTask: PerformanceMeasurableTask {
    var startEventName: String?
    var resultMetrics: ResultMetrics.Type { Constants.Metrics.Task.WebViewDownload.self }

    let downloader: WebViewDownloader
    let experimentsReader: ExperimentsReader

    init(downloader: WebViewDownloader, experimentsReader: ExperimentsReader) {
        self.downloader = downloader
        self.experimentsReader = experimentsReader
    }

    func start(completion: @escaping ResultClosure<Void>) {
        if let experiments = experimentsReader.experiments, experiments.isNativeWebViewCacheEnabled.value {
            completion(VoidSuccess)
            return
        }
        downloader.download { result in
            result.map({ _ in }).sink(completion)
        }
    }
}
