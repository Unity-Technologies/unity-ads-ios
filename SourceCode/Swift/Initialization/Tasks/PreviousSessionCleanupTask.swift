import Foundation

final class PreviousSessionCleanupTask: PerformanceMeasurableTask {
    var startEventName: String?
    var resultMetrics: ResultMetrics.Type { Constants.Metrics.Task.Reset.self }
    private let loggerSettingsReader: LoggerSettingsReader
    private let fileManager: FileManager
    private let legacyTask: PerformanceMeasurableTask
    private let storage: KeyValueStorage
    private let cleanupKeys: [String]
    init(loggerSettingsReader: LoggerSettingsReader,
         fileManager: FileManager = .default,
         legacyTask: PerformanceMeasurableTask,
         storage: KeyValueStorage,
         cleanupKeys: [String]) {
        self.loggerSettingsReader = loggerSettingsReader
        self.fileManager = fileManager
        self.legacyTask = legacyTask
        self.storage = storage
        self.cleanupKeys = cleanupKeys
    }

    func start(completion: @escaping ResultClosure<Void>) {
        try? fileManager.deleteFile(at: loggerSettingsReader.logsFileURL)
        cleanupKeys.forEach { storage.delete(forKey: $0) }
        legacyTask.start(completion: completion)
    }

}
