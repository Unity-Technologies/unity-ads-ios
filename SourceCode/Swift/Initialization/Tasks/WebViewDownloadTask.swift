import Foundation

final class WebViewDownloadTask: PerformanceMeasurableTask {
    var startEventName: String?
    var resultMetrics: ResultMetrics.Type { Constants.Metrics.Task.WebViewDownload.self }

    let downloader: WebViewDownloader

    init(downloader: WebViewDownloader) {
        self.downloader = downloader
    }

    func start(completion: @escaping ResultClosure<Void>) {
        downloader.download { result in
            result.map({ _ in }).sink(completion)
        }
    }
}
