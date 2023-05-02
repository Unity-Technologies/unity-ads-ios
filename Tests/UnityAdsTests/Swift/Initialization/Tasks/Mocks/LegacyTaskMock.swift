import Foundation
@testable import UnityAds

final class LegacyTaskMock: PerformanceMeasurableTask {
   func start(completion: @escaping ResultClosure<Void>) {
       completion(VoidSuccess)
   }

   var resultMetrics: ResultMetrics.Type { Constants.Metrics.Task.Reset.self }

   var startEventName: String?

}
