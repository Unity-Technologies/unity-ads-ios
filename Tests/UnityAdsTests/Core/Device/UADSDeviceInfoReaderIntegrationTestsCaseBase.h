#import <XCTest/XCTest.h>
#import "UADSPrivacyStorageMock.h"
#import "UADSDeviceTestsHelper.h"
#import "SDKMetricsSenderMock.h"

#ifndef UADSDeviceInfoReaderIntegrationTestsCaseBase_h
#define UADSDeviceInfoReaderIntegrationTestsCaseBase_h

@interface UADSDeviceInfoReaderIntegrationTestsCaseBase : XCTestCase
@property (nonatomic, strong) UADSDeviceTestsHelper *tester;
@property (nonatomic, strong) SDKMetricsSenderMock *metricsMock;
@property (nonatomic, strong) UADSPrivacyStorageMock *privacyStorageMock;

- (NSDictionary *)getDataFromSut;
- (BOOL)          isDeviceInfoReaderExtended;
- (void)          validateMetrics: (NSArray<UADSMetric *> *)expectedMetrics;
- (void)setExpectedPrivacyModeTo: (UADSPrivacyMode)mode
         withUserBehaviouralFlag: (BOOL)flag;
- (NSDictionary *)                         piiExpectedData;
- (void)setPrivacyResponseState: (UADSPrivacyResponseState)state;
- (NSArray *)                              expectedKeysNoPII;
- (NSArray *)expectedKeysWithPIIIncludeNonBehavioral: (BOOL)include;
- (NSArray *)expectedKeysMinIncludeNonBehavioral: (BOOL)include;
- (NSArray *)expectedKeysNoPIIIncludeNonBehavioral: (BOOL)include;
- (id<UADSPrivacyConfig, UADSClientConfig>)privacyConfig;
- (NSDictionary *)                         piiFullContentData;
@end

#endif /* UADSDeviceInfoReaderIntegrationTestsCaseBase_h */
