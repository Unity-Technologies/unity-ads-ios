import Foundation

protocol PerformanceMeasurable {
    var resultMetrics: ResultMetrics.Type { get }
    var startEventName: String? { get }
}

protocol PerformanceMeasurableTask: Task, PerformanceMeasurable {}

final class TaskPerformanceDecorator: Task {
    let metricSender: MetricSender
    let performanceMeasurer: PerformanceMeasurer<String>
    let original: PerformanceMeasurableTask
    init(original: PerformanceMeasurableTask,
         metricSender: MetricSender,
         performanceMeasurer: PerformanceMeasurer<String>) {
        self.original = original
        self.metricSender = metricSender
        self.performanceMeasurer = performanceMeasurer
    }

    func start(completion: @escaping ResultClosure<Void>) {
        sendStartedMetricIfNeeded()
        let name = original.resultMetrics.SystemName
        performanceMeasurer.start(for: name)
        original.start { result in
            let duration = self.performanceMeasurer.stop(for: name)
            self.sendMetrics(for: result, duration: duration)
            completion(result)
        }
    }

    private func sendMetrics(for result: UResult<Void>, duration: TimeInterval?) {
        guard let duration = duration else { return } // log?
        result.map(successMetricName)
              .recover(failureMetric)
              .map({ convertToMetric($0, duration: duration) })
              .do({ metricSender.send(metrics: [.performance($0)], completion: { _ in }) })
    }

    private func convertToMetric( _ name: String, duration: TimeInterval) -> MetricValue {
        .init(name: name, duration: duration, info: [:])
    }

    private var finalMetricNameBase: String {
        "\(original.resultMetrics.SystemName)_task"
    }
    private func successMetricName() -> String {
        "\(finalMetricNameBase)_success"
    }

    private func failureMetric(for error: Error) -> String {
        "\(finalMetricNameBase)_failure"
    }

    private func sendStartedMetricIfNeeded() {
        if let startEvent = original.startEventName {
            metricSender.send(metrics: [.single(startEvent)], completion: { _ in })
        }
    }
}
