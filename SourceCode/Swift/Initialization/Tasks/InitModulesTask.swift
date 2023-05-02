import Foundation

final class InitModulesTask: PerformanceMeasurableTask {
    var startEventName: String?
    var resultMetrics: ResultMetrics.Type { Constants.Metrics.Task.InitModules.self }

    private let legacyTask: PerformanceMeasurableTask
    private let deviceInfoReader: DeviceInfoBodyStrategy

    init(legacyTask: PerformanceMeasurableTask,
         deviceInfoReader: DeviceInfoBodyStrategy) {
        self.legacyTask = legacyTask
        self.deviceInfoReader = deviceInfoReader
    }

    func start(completion: @escaping ResultClosure<Void>) {
        initDeviceStaticInfo()
        legacyTask.start(completion: completion)
    }

    private func initDeviceStaticInfo() {
        deviceInfoReader.initializeStaticInfo()
    }

}
