import Foundation

final class InitializationStateTaskBridge: PerformanceMeasurableTask {
    var startEventName: String?
    let resultMetrics: ResultMetrics.Type
    let onComplete: (USRVInitializeTask) -> Void
    private let obj: USRVInitializeTask
    init(objcState: USRVInitializeTask, resultMetrics: ResultMetrics.Type, onComplete: @escaping (USRVInitializeTask) -> Void) {
        self.obj = objcState
        self.resultMetrics = resultMetrics
        self.onComplete = onComplete
    }

    func start(completion: @escaping ResultClosure<Void>) {
        obj.start(completion: { [self] in
            self.onComplete(self.obj)
            completion(VoidSuccess)
        }, error: {
            self.onComplete(self.obj)
            completion(.failure($0))
        })
    }
}
