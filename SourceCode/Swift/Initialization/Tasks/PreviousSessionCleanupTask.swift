import Foundation

final class PreviousSessionCleanupTask: PerformanceMeasurableTask {
    var startEventName: String?
    var resultMetrics: ResultMetrics.Type { Constants.Metrics.Task.Reset.self }
    private let loggerSettingsReader: LoggerSettingsReader
    private let fileManager: FileManager
    private let legacyTask: PerformanceMeasurableTask
    init(loggerSettingsReader: LoggerSettingsReader,
         fileManager: FileManager = .default,
         legacyTask: PerformanceMeasurableTask) {
        self.loggerSettingsReader = loggerSettingsReader
        self.fileManager = fileManager
        self.legacyTask = legacyTask
    }

    func start(completion: @escaping ResultClosure<Void>) {
        try? fileManager.deleteFile(at: loggerSettingsReader.logsFileURL)
        legacyTask.start(completion: completion)
    }

}
