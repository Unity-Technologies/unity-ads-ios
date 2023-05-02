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
- (void)setExpectedUserBehaviouralFlag: (BOOL)flag;
- (NSDictionary *)                         piiExpectedData;
- (void)setPrivacyResponseState: (UADSPrivacyResponseState)state;
- (NSArray *)                              allExpectedKeys;
- (NSArray *)expectedKeysWithPIIWithNonBehavioral: (BOOL)withUserNonBehavioral;
- (NSArray *)expectedMinKeys;
- (NSArray *)expectedMinKeysWithoutNonBehavioral;
- (NSArray *)allExpectedKeysWithNonBehavioral: (BOOL)withUserNonBehavioral;
- (NSDictionary *)                         piiFullContentData;
- (void)setShouldSendNonBehavioural: (BOOL)flag;
@end

#endif /* UADSDeviceInfoReaderIntegrationTestsCaseBase_h */
