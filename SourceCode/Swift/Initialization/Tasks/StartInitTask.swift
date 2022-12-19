import Foundation

final class StartInitTask<F: TaskFactory>: PerformanceMeasurableTask {
    var startEventName: String? = Constants.Metrics.Task.Initializer.Started
    var resultMetrics: ResultMetrics.Type { Constants.Metrics.Task.Initializer.self }
    private let runner: SyncTaskRunner<F>
    init(factory: F, sequence: [F.Element]) {
        self.runner = .init(factory: factory, sequence: sequence)
    }

    func start(completion: @escaping ResultClosure<Void>) {
        runner.start(completion: completion)
    }
}
