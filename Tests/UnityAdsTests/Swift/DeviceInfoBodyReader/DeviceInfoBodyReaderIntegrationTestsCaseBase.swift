import XCTest
@testable import UnityAds

class DeviceInfoBodyReaderIntegrationTestsCaseBase: XCTestCase {

    var tester = UADSDeviceTestsHelper()
    var telephonyProviderMock = TelephonyInfoProviderMock()
    var serviceProvider = UnityAdsServiceProvider()
    var aggregator = USRVJsonStorageAggregator.default()
    var jsonStorageBridge: JSONStorageBridge {
        serviceProvider.jsonStorageObjCBridge
    }
    var sdkStateStorageMock = SDKStateStorageMock()
    var metricsSenderMock = MetricsSenderMock()
    var timeReaderMock = TimeReaderMock()
    var minContentReader: StorageContentReader {
        JSONStorageContentNormalizer.minStorageContentReader(with: jsonStorageBridge)
    }
    var extendedContentReader: StorageContentReader {
        JSONStorageContentNormalizer.extendedStorageContentReader(with: jsonStorageBridge)
    }
    override func setUp() {
        serviceProvider = UnityAdsServiceProvider(telephonyProvider: telephonyProviderMock)
        sdkStateStorageMock = .init()
        jsonStorageBridge.jsonStorageReaderClosure = {[weak aggregator] in
            aggregator?.getValueForKey($0)
        }

        jsonStorageBridge.jsonStorageReaderContentClosure = { [weak aggregator] in
            (aggregator?.getContents() as? [String: Any]) ?? [:]
        }

        telephonyProviderMock = .init()
        tester.clearAllStorages()
    }

    var deviceInfoType: DeviceInfoType = .extended

    var dataFromSut: [String: Any] {
        let sessionInfoStorage = SessionInfoStorage(settings: .defaultSettings(privateStorage: jsonStorageBridge))
        let trackingStatusReader = TrackingStatusReaderBase()
        let gameIdProvider = SDKGameSettingsProviderMock()

        let builderConfig = DeviceInfoBodyReaderBuilder.Config(sessionInfoStorage: sessionInfoStorage,
                                                               trackingStatusReader: trackingStatusReader,
                                                               gameSettingsReader: gameIdProvider,
                                                               sdkStateStorage: sdkStateStorageMock,
                                                               persistenceStorage: jsonStorageBridge,
                                                               logger: ConsoleLogger(),
                                                               timeReader: timeReaderMock,
                                                               telephonyInfoProvider: telephonyProviderMock,
                                                               performanceMeasurer: PerformanceMeasurer(timeReader: timeReaderMock),
                                                               metricsSender: metricsSenderMock)

        let builder = DeviceInfoBodyReaderBuilder(baseConfig: builderConfig)

        return builder.deviceInfoBodyReader.getDeviceInfoBody(of: deviceInfoType)
    }

    var piiExpectedData: [String: String] {
        [
            JSONStorageKeys.VendorIdentifier: "vendorIdentifier",
            JSONStorageKeys.AdvertisingTrackingId: "advertisingTrackingId"
        ]
    }

    var allExpectedKeys: [Any] {
        tester.allExpectedKeys()
    }

    func allExpectedKeys(includeNonBehavioral: Bool) -> [Any] {
        tester.allExpectedKeys(withNonBehavioral: includeNonBehavioral)
    }

    func allExpectedKeysWithPII(includeNonBehavioral: Bool) -> [Any] {
        var allKeys =   tester.allExpectedKeys(withNonBehavioral: includeNonBehavioral)
        allKeys.append(contentsOf: Array(piiExpectedData.keys))
        return allKeys

    }
    var expectedKeysWithPII: [Any] {
        var allKeys = allExpectedKeys
        allKeys.append(contentsOf: Array(piiExpectedData.keys))
        return allKeys
    }

    var expectedMinKeys: [Any] {
        tester.allExpectedKeysFromMinInfo(withUserNonBehavioral: true)
    }

    var expectedMinKeysWithoutNonBehavioral: [Any] {
        tester.allExpectedKeysFromMinInfo(withUserNonBehavioral: false)
    }

    func setExpectedUserBehavioralFlag(_ flag: Bool) {
        tester.commitNonBehavioral(flag)
    }

    func setPrivacyState(_ state: PrivacyState) {
        sdkStateStorageMock.privacyState = state
    }

    func setShouldSendNonBehavioural(_ flag: Bool) {
        sdkStateStorageMock.shouldSendNonBehavioural = true
    }

    func commitAllTestData() {
        tester.commitAllTestData()
    }

    func validateMetrics(_ expected: [MetricsType], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(expected, metricsSenderMock.metricsStorage, file: file, line: line)
    }
}

final class SDKGameSettingsProviderMock: SDKGameSettingsProvider {
    var gameID: String = "1234567890"
    var isTestModeEnabled: Bool = true
}

final class TelephonyInfoProviderMock: TelephonyInfoProvider & CountryCodeProvider {
    var dynamicInfo: TelephonyInfoDynamicInfo {
        .init(networkStatusString: "networkStatusString",
              networkType: 1,
              operatorName: "operatorName",
              operatorCode: "operatorCode")
    }

    var countryCode: String {
        "countryCode"
    }

}

final class MetricsSenderMock: MetricSender {

    private(set) var metricsStorage: [MetricsType] = []
    var expectedResult: UResult<Void> = VoidSuccess
    func send(metrics: [MetricsType], completion: @escaping ResultClosure<Void>) {
        metricsStorage.append(contentsOf: metrics)
        completion(expectedResult)
    }
}

final class SDKStateStorageMock: PrivacyStateReader, ExperimentsReader, AppStartTimeProvider {
    var shouldSendNonBehavioural: Bool = false

    var privacyState: PrivacyState = .denied

    var experiments: ConfigExperiments? {
        try? .init(dictionary: ["s_din": true])
    }

    var appStartTime: TimeInterval { 1 }

    let privacyStorage = PrivacyStateStorage()

}
