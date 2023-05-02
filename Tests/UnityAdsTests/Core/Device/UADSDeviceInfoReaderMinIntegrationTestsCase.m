#import "UADSDeviceInfoReaderIntegrationTestsCaseBase.h"
#import "UADSFactoryConfigMock.h"
@interface UADSDeviceInfoReaderMinIntegrationTestsCase : UADSDeviceInfoReaderIntegrationTestsCaseBase
@end

@implementation UADSDeviceInfoReaderMinIntegrationTestsCase

- (void)setUp {
    [super setUp];
}

- (BOOL)isDeviceInfoReaderExtended {
    return false;
}

- (void)test_contains_minimum_required_info_include_non_behavioural_true {
    [self.tester commitAllTestData];
    [self setExpectedUserBehaviouralFlag: true];
    [self.tester validateDataContains: [self getDataFromSut]
                              allKeys: [self expectedMinKeys]];
    [self validateMetrics: @[]];
}

- (void)test_contains_minimum_required_info_include_non_behavioural_false {
    [self.tester commitAllTestData];
    [self setExpectedUserBehaviouralFlag: false];
    [self.tester validateDataContains: [self getDataFromSut]
                              allKeys: [self expectedMinKeys]];
    [self validateMetrics: @[]];
}

- (void)test_contains_minimum_required_info_does_not_include_non_behavioural {
    [self.tester commitAllTestData];
    [self.tester validateDataContains: [self getDataFromSut]
                              allKeys: [self expectedMinKeysWithoutNonBehavioral]];
    [self validateMetrics: @[]];
}


@end
