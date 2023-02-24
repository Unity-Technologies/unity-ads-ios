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

- (void)test_contains_minimum_required_info_include_non_behavioural {
    [self.tester commitAllTestData];
    [self setExpectedPrivacyModeTo: kUADSPrivacyModeMixed withUserBehaviouralFlag: true];
    [self.tester validateDataContains: [self getDataFromSut]
                              allKeys: [self expectedKeysMinIncludeNonBehavioral: true]];
    [self validateMetrics: @[]];
}


@end
