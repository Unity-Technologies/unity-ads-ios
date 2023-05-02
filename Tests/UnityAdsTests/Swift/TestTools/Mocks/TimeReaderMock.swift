import Foundation
@testable import UnityAds

final class TimeReaderMock: TimeReader, BootTimeReader, TimeZoneReader {
    var timeZoneOffset: Int = 10

    var expectedTimeZone = "TimeZone"

    func formattedTimeZone(daylightSavingTime: Bool) -> String {
        expectedTimeZone
    }

    var elapsedRealTime: UInt64 = 1

    var upTime: TimeInterval = 2

    var bootTime: TimeInterval = 3

    var expectedInterval: TimeInterval = 4
    var currentTimeStampCalled = 0
    func currentTimestamp(in: TimeReaderInterval) -> TimeInterval {
        currentTimeStampCalled += 1
        return expectedInterval
    }

}
