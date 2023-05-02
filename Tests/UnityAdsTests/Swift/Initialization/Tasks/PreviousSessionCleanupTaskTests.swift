import XCTest
@testable import UnityAds

final class PreviousSessionCleanupTaskTests: XCTestCase {

    private var loggerSettingsReader: LoggerSettingsReader = SDKSettingsStorage()
    private var storageMock = KeyValueStorageMock()
    private var cleanupKeys = ["test", "test2"]
    private var sut: PreviousSessionCleanupTask {
        .init(loggerSettingsReader: loggerSettingsReader,
              fileManager: fileManager,
              legacyTask: TaskMock(),
              storage: storageMock,
              cleanupKeys: cleanupKeys)
    }

    private var fileManager = FileManager.default
    private var dumpFileExists: Bool {
        fileManager.fileExists(atPath: loggerSettingsReader.logsFileURL.path)
    }
    override func setUpWithError() throws {
        loggerSettingsReader = SDKSettingsStorage()
        storageMock = KeyValueStorageMock()
        try? fileManager.deleteFile(at: loggerSettingsReader.logsFileURL)
    }

    func test_task_deletes_dump_file() throws {
        verifyNoTestDataSaved()
        saveTestDataForKeys()
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
        verifyNoTestDataSaved()
        XCTAssertEqual(storageMock.deleteCount, cleanupKeys.count)
    }

    func verifyNoTestDataSaved() {
        cleanupKeys.forEach {
            let data: String? = storageMock.getValue(for: $0)
            XCTAssertNil(data)
        }
    }

    func saveTestDataForKeys() {
        cleanupKeys.forEach {
            storageMock.saveValue(value: "test", forKey: $0)
            XCTAssertNotNil(storageMock.getValue(for: $0))
        }
    }
}
