import XCTest
@testable import UnityAds

class ExtendedDeviceInfoBodyReaderIntegrationTestsCaseBase: DeviceInfoBodyReaderIntegrationTestsCaseBase {

    func test_contains_default_device_info_no_nonbehavioural() {
        tester.commitUserDefaultsTestData()
        tester.commitNonBehavioral(true)
        tester.validateDataContains(dataFromSut,
                                    allKeys: tester.expectedKeysFromDefaultInfo(withUserNonBehavioral: false))
        validateMetrics([successLatencyMetric])
    }

    func test_contains_attributes_from_storage_no_non_behavioural() {
        commitAllTestData()
        tester.commitNonBehavioral(true)
        tester.validateDataContains(dataFromSut,
                                    allKeys: self.allExpectedKeys(includeNonBehavioral: false))
        validateMetrics([successLatencyMetric])
    }

    func test_tracking_is_disabled_does_not_contain_pii_attributes_no_non_behavioural() {
        commitAllTestData()
        tester.commitNonBehavioral(true)
        setPrivacyState(.denied)

        tester.validateDataContains(dataFromSut,
                                    allKeys: self.allExpectedKeys(includeNonBehavioral: false))
        validateMetrics([successLatencyMetric])
    }

    func test_tracking_is_disabled_does_not_contain_pii_attributes_include_non_behavioural() {
        commitAllTestData()
        tester.commitNonBehavioral(true)
        setPrivacyState(.denied)
        setShouldSendNonBehavioural(true)

        tester.validateDataContains(dataFromSut,
                                    allKeys: self.allExpectedKeys(includeNonBehavioral: true))
        validateMetrics([successLatencyMetric])
    }

    func test_tracking_is_enabled_contains_pii_attributes_no_non_behavioral() {
        commitAllTestData()
        setPrivacyState(.allowed)
        setExpectedUserBehavioralFlag(false)

        tester.validateDataContains(dataFromSut,
                                    allKeys: self.allExpectedKeysWithPII(includeNonBehavioral: false))
        validateMetrics([successLatencyMetric])
    }

    func test_tracking_is_enabled_contains_pii_attributes_include_non_behavioral() {
        commitAllTestData()
        setPrivacyState(.allowed)
        setExpectedUserBehavioralFlag(false)
        setShouldSendNonBehavioural(true)

        tester.validateDataContains(dataFromSut,
                                    allKeys: self.allExpectedKeysWithPII(includeNonBehavioral: true))
        validateMetrics([successLatencyMetric])
    }

    var successLatencyMetric: MetricsType {
        .performance(.init(name: Constants.Metrics.Collection.Success, duration: 0, info: [:]))
    }
}
