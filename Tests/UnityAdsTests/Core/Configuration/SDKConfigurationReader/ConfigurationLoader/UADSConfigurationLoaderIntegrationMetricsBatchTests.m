
#import "UADSConfigurationLoaderIntegrationMetricsBatchTests.h"
#import "UADSMetricSenderWithBatch.h"
#import "UADSLoggerMock.h"
#import "UADSMetricSelectorMock.h"

@interface UADSConfigurationLoaderIntegrationMetricsBatchTests ()
@property (nonatomic, strong) id<UADSConfigurationCRUD> configCRUD;
@property (nonatomic, strong) UADSMetricSelectorMock *selectorMock;
@end


@implementation UADSConfigurationLoaderIntegrationMetricsBatchTests

- (void)setUp {
    [super setUp];
    _configCRUD = [UADSConfigurationCRUDBase new];
    _selectorMock = [UADSMetricSelectorMock new];
    _selectorMock.shouldSend = true;
    self.saverMock.original = _configCRUD;
}

- (void)test_config_failure_triggers_batcher_to_send_metrics__by_saving_empty_config {
    self.webRequestFactoryMock.expectedRequestData = @[[NSData new], [NSData new]];

    [self callSUTExpectingFailWithConfig:  [self factoryConfigWithExperiments: @{ @"tsi": @"true" }]];
    [self.saverMock saveConfiguration: [USRVConfiguration newFromJSON:@{}]];
    
    [self validateCreatedRequestAtIndex: 0
                   withExpectedHostHame: self.expectedHostName
                     andExpectedQueries: nil];

    [self validateCreateRequestCalledNumberOfTimes: 2];
    [self validateConfigWasSavedToPersistenceNumberOfTimes: 1];
    UADSMetric *configFailureMetric = [self.deviceInfoTester configLatencyFailureMetricWithReason: kUADSConfigurationLoaderParsingError];

    [self validateMetrics: @[
         self.deviceInfoTester.infoCollectionLatencyMetrics,
         self.deviceInfoTester.tsiNoSessionIDMetrics,
         self.deviceInfoTester.infoCompressionLatencyMetrics,
         [configFailureMetric updatedWithValue: @(0)],
         self.deviceInfoTester.emergencyOffMetrics,
    ]];
}

- (id<ISDKMetrics, ISDKPerformanceMetricsSender>)metricSender {
    return [UADSMetricSenderWithBatch newWithMetricSender: self.metricsSenderMock
                                  andConfigurationSubject: self.configCRUD
                                              andSelector: _selectorMock
                                                andLogger: [UADSLoggerMock new]];
}

@end
