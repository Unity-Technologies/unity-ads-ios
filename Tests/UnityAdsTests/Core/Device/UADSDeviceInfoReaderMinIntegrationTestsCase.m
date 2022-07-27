#import "UADSDeviceInfoReaderIntegrationTestsCaseBase.h"
#import "UADSFactoryConfigMock.h"
@interface UADSDeviceInfoReaderMinIntegrationTestsCase : UADSDeviceInfoReaderIntegrationTestsCaseBase
@property (nonatomic, strong) UADSFactoryConfigMock *configMock;
@end

@implementation UADSDeviceInfoReaderMinIntegrationTestsCase

- (void)setUp {
    [super setUp];
    _configMock = [UADSFactoryConfigMock new];
}

- (BOOL)isDeviceInfoReaderExtended {
    return false;
}

- (void)test_contains_minimum_required_info_include_non_behavioural {
    [self runTestFlowForNonBehavioralFlagTo: YES];
}

- (void)runTestFlowForNonBehavioralFlagTo: (BOOL)include {
    [self.tester commitAllTestData];
    [self setIncludeNonBehaviouralTo: include];
    [self setExpectedPrivacyModeTo: kUADSPrivacyModeMixed
           withUserBehaviouralFlag: include];
    [self.tester validateDataContains: [self getDataFromSut]
                              allKeys: [self expectedKeysMinIncludeNonBehavioral: include]];
    [self validateMetrics: @[]];
}

- (void)setIncludeNonBehaviouralTo: (BOOL)include {
    _configMock.isPrivacyRequestEnabled = include;
}

- (id<UADSPrivacyConfig>)privacyConfig {
    return _configMock;
}

@end
