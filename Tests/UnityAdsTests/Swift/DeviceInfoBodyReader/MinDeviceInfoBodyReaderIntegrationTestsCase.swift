import XCTest
@testable import UnityAds

class MinDeviceInfoBodyReaderIntegrationTestsCase: DeviceInfoBodyReaderIntegrationTestsCaseBase {

    func test_contains_minimum_required_info_include_non_behavioural_true() {
        deviceInfoType = .minimal
        commitAllTestData()
        setExpectedUserBehavioralFlag(true)
        tester.validateDataContains(dataFromSut, allKeys: expectedMinKeys)
        validateMetrics([])
    }

    func test_contains_minimum_required_info_include_non_behavioural_false() {
        deviceInfoType = .minimal
        commitAllTestData()
        setExpectedUserBehavioralFlag(false)
        tester.validateDataContains(dataFromSut, allKeys: expectedMinKeys)
        validateMetrics([])
    }

    func test_contains_minimum_required_info_does_notinclude_non_behavioural() {
        deviceInfoType = .minimal
        commitAllTestData()
        tester.validateDataContains(dataFromSut, allKeys: expectedMinKeysWithoutNonBehavioral)
        validateMetrics([])
    }
}
