#import <XCTest/XCTest.h>
#import "UADSConfigurationLoaderBuilder.h"
#import "WebRequestFactoryMock.h"
#import "UADSConfigurationPersistenceMock.h"
#import "SDKMetricsSenderMock.h"
#import "UADSLoaderIntegrationTestsHelper.h"
#import "UADSDeviceTestsHelper.h"
#import "UADSPrivacyStorage.h"
#import "UADSClientConfig.h"

#ifndef UADSConfigurationLoaderIntegrationTestsBase_h
#define UADSConfigurationLoaderIntegrationTestsBase_h


@interface UADSConfigurationLoaderIntegrationTestsBase : XCTestCase
@property (strong, nonatomic) WebRequestFactoryMock *webRequestFactoryMock;
@property (strong, nonatomic) UADSConfigurationPersistenceMock *saverMock;
@property (strong, nonatomic) SDKMetricsSenderMock *metricsSenderMock;
@property (strong, nonatomic) UADSLoaderIntegrationTestsHelper *helper;
@property (strong, nonatomic) UADSDeviceTestsHelper *deviceInfoTester;
@property (strong, nonatomic) id<UADSPrivacyResponseSaver, UADSPrivacyResponseReader> privacyStorage;

- (void)validateMetrics: (NSArray<UADSMetric *> *)expectedMetrics;
- (id<UADSConfigurationLoader>)sutForConfig: (id<UADSClientConfig>)config;

- (void)validateCreatedRequestAtIndex: (NSInteger)index
                 withExpectedHostHame: (NSString *)hostName
                      andBodyDataKeys: (NSArray<NSString *> *)bodyDataKeys;

- (void)validateCreatedRequestAtIndex: (NSInteger)index
                 withExpectedHostHame: (NSString *)hostName
                   andExpectedQueries: (NSDictionary *)queryAttributes;


- (void)validateCreatedRequestAtIndex: (NSInteger)index
           withExpectedCompressedKeys: (NSArray *)keys;
- (void)validateCreateRequestCalledNumberOfTimes: (NSInteger)count;
- (void)validateConfigWasSavedToPersistenceNumberOfTimes: (NSInteger)count;
- (id<UADSClientConfig>)factoryConfigWithExperiments: (NSDictionary *)experiments;
- (NSString *)                                   expectedHostName;
- (id<UADSConfigurationLoader>)callSUTExpectingFailWithConfig: (id<UADSClientConfig>)config;
- (void)callSUTExpectingSuccessWithConfig: (id<UADSClientConfig>)config;
- (NSArray<NSString *> *)appendCommonKeys: (NSArray<NSString *> *)array;

- (id<UADSConfigurationSaver>)                   configSaver;
- (id<ISDKMetrics, ISDKPerformanceMetricsSender>)metricSender;
@end

#endif /* UADSConfigurationLoaderIntegrationTestsBase_h */
