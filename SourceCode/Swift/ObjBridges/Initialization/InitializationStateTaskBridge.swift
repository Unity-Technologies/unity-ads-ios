import Foundation

final class InitializationStateTaskBridge: PerformanceMeasurableTask {
    var startEventName: String?
    let resultMetrics: ResultMetrics.Type

    private let obj: USRVInitializeTask
    init(objcState: USRVInitializeTask, resultMetrics: ResultMetrics.Type) {
        self.obj = objcState
        self.resultMetrics = resultMetrics
    }

    func start(completion: @escaping ResultClosure<Void>) {
        obj.start(completion: { completion(VoidSuccess) }, error: { completion(.failure($0)) })
    }
}
