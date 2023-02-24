import XCTest
@testable import UnityAds

final class PreviousSessionCleanupTaskTests: XCTestCase {

    private var loggerSettingsReader: LoggerSettingsReader = SDKSettingsStorage()
    private var sut: PreviousSessionCleanupTask {
        .init(loggerSettingsReader: loggerSettingsReader,
              fileManager: fileManager,
              legacyTask: LegacyTaskMock())
    }

    private var fileManager = FileManager.default
    private var dumpFileExists: Bool {
        fileManager.fileExists(atPath: loggerSettingsReader.logsFileURL.path)
    }
    override func setUpWithError() throws {
        loggerSettingsReader = SDKSettingsStorage()
        try? fileManager.deleteFile(at: loggerSettingsReader.logsFileURL)
    }

    func test_task_deletes_dump_file() throws {
        XCTAssertEqual(dumpFileExists, false)

        try fileManager.saveStringToFile("test", toFile: loggerSettingsReader.logsFileURL)
        XCTAssertEqual(dumpFileExists, true)
        let exp = defaultExpectation
        sut.start { result in
            XCTAssertSuccess(result)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
        XCTAssertEqual(dumpFileExists, false)
    }
}

private class LegacyTaskMock: PerformanceMeasurableTask {
    func start(completion: @escaping ResultClosure<Void>) {
        completion(VoidSuccess)
    }

    var resultMetrics: ResultMetrics.Type { Constants.Metrics.Task.Reset.self }

    var startEventName: String?

}
