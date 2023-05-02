import Foundation
@testable import UnityAds

final class TaskMock: PerformanceMeasurableTask {
    private(set) var  startCalled = 0
    func start(completion: @escaping ResultClosure<Void>) {
        startCalled += 1
        completion(VoidSuccess)
    }

    var resultMetrics: ResultMetrics.Type { Constants.Metrics.Task.Reset.self }

    var startEventName: String?

}
