import XCTest
@testable import UnityAds

final class InitModulesTaskTests: XCTestCase {

    private var deviceInfoReaderMock = DeviceInfoReaderMock()
    private var sut: InitModulesTask {
        .init(legacyTask: LegacyTaskMock(),
              deviceInfoReader: deviceInfoReaderMock)
    }

    func test_init_calls_static_device_info() {
        XCTAssertEqual(deviceInfoReaderMock.staticInfoCalledTimes, 0)
        sut.start { _ in
            XCTAssertEqual(self.deviceInfoReaderMock.staticInfoCalledTimes, 1)
        }
    }
}

final class DeviceInfoReaderMock: DeviceInfoReader, DeviceInfoBodyStrategy {
    func initializeStaticInfo() {
        staticInfoCalledTimes += 1
    }

    var expected: [String: Any] = [:]

    func getDeviceInfoBody(of type: DeviceInfoType) -> [String: Any] {
        return expected
    }

    var staticInfoCalledTimes = 0

    var countryCode: String = ""

    var osName: String = "osName"

    var deviceInfo: DeviceInfo {
        DeviceInfo(staticInfo: staticInfo,
                   dynamic: dynamicInfo,
                   countryIso: countryCode)
    }

    var staticInfo: StaticDeviceInfo {
        return StaticDeviceInfo(bundle: Bundle.main.staticInfo,
                                screen: UIScreen.main.staticInfo,
                                device: UIDevice.current.staticInfo,
                                userAgent: "")
    }
    var dynamicInfo: DynamicDeviceInfo {
        DynamicDeviceInfo(deviceInfo: UIDevice.current.dynamicInfo,
                          screenInfo: UIScreen.main.dynamicInfo,
                          telephonyInfo: TelephonyInfoDynamicInfo(networkStatusString: "", networkType: 0, operatorName: "", operatorCode: ""),
                          audioInfo: AVAudioSession.sharedInstance().dynamicInfo,
                          timeInfo: AppTimeInfo(appStartTime: 0,
                                                appUptime: 0,
                                                timeZoneOffset: 0,
                                                timeZone: "",
                                                systemBootTime: 0,
                                                currentTimestamp: 0),
                          localeInfo: LocaleStaticInfo(language: "", preferredLocale: ""),
                          sessionInfo: .empty,
                          appStateInfo: GameStateInfo(startTime: 0, isTestModeEnabled: false, isActive: true),
                          connectionType: "")
    }
}

extension SessionInfo {
    static var empty: Self {
        .init(sessionID: "",
              gameSessionID: 0,
              analyticsSessionID: "",
              analyticsUserID: "",
              idfi: "",
              userNonBehavioralFlag: false)
    }
}
