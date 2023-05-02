import XCTest
@testable import UnityAds
// swiftlint:disable discouraged_optional_boolean

// time reader into integration to test multithread.
final class AppStartTimeSaverMock: AppStartTimeSaver {
    var startTime: TimeInterval = 0
    func save(startTime: TimeInterval) {
        self.startTime = startTime
    }
}

final class LoggerMock: Logger {
    var loggedRecords = [LogRecord]()

    func logRecord(_ record: LogRecord) {
        loggedRecords.append(record)
    }
}

final class SessionInfoReaderMock: SessionInfoReader {
    var auid: String = "auid"
    var sessionID: String = "sessionID"
    var gameSessionID: Int64 = 1
    var analyticsSessionID: String = "analyticsSessionID"
    var analyticsUserID: String = "analyticsUserID"
    var idfi: String = "idfi"
    var userNonBehavioralFlag: Bool?

    var sessionInfo: SessionInfo {
        .init(sessionID: sessionID,
              gameSessionID: gameSessionID,
              analyticsSessionID: analyticsSessionID,
              analyticsUserID: analyticsUserID,
              idfi: idfi,
              userNonBehavioralFlag: userNonBehavioralFlag)
    }
}

final class StartInitTaskTests: XCTestCase {
    var taskFactoryMock = InitTaskFactoryMock()
    var timeReaderMock = TimeReaderMock()
    var appStartTimeSaverMock = AppStartTimeSaverMock()
    var loggerMock = LoggerMock()
    var settingsMock = SDKGameSettingsProviderMock()
    var sessionInfoReaderMock = SessionInfoReaderMock()

    var sut: StartInitTask<InitTaskFactoryMock> {
        StartInitTask(factory: taskFactoryMock,
                      sequence: ["doesnt mater"],
                      timeReader: timeReaderMock,
                      appStartTimeSaver: appStartTimeSaverMock,
                      logger: loggerMock,
                      settingProvider: settingsMock,
                      sessionInfoReader: sessionInfoReaderMock)
    }

    override func setUpWithError() throws {
        taskFactoryMock = InitTaskFactoryMock()
        timeReaderMock = TimeReaderMock()
        appStartTimeSaverMock = AppStartTimeSaverMock()
    }

    func test_calls_reader_saver_and_task() {
        sut.start(completion: { _ in })
        XCTAssertEqual(taskFactoryMock.taskMock.startCalled, 1)
        XCTAssertEqual(timeReaderMock.currentTimeStampCalled, 1)
        XCTAssertEqual(appStartTimeSaverMock.startTime, timeReaderMock.expectedInterval)
        XCTAssertEqual(loggerMock.loggedRecords.count, 1, "Should have log init message")
    }
}
