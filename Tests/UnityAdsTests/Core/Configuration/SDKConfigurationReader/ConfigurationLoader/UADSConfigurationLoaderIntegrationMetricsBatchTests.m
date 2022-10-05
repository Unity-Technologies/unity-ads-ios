
#import "UADSConfigurationLoaderIntegrationMetricsBatchTests.h"
#import "UADSMetricSenderWithBatch.h"
#import "UADSLoggerMock.h"

@interface UADSConfigurationLoaderIntegrationMetricsBatchTests ()
@property (nonatomic, strong) id<UADSConfigurationCRUD> configCRUD;
@end


@implementation UADSConfigurationLoaderIntegrationMetricsBatchTests

- (void)setUp {
    [super setUp];
    _configCRUD = [UADSConfigurationCRUDBase new];
    self.saverMock.original = _configCRUD;
}

- (void)test_config_failure_triggers_batcher_to_send_metrics__by_saving_empty_config {
    self.webRequestFactoryMock.expectedRequestData = @[[NSData new], [NSData new], [NSData new]];

    [self callSUTExpectingFailWithConfig:  [self factoryConfigWithExperiments: @{ }]];
    [self.saverMock saveConfiguration: [USRVConfiguration newFromJSON: @{}]];

    [self validateCreatedRequestAtIndex: 0
                   withExpectedHostHame: self.expectedHostName
                     andExpectedQueries: nil];

    [self validateCreateRequestCalledNumberOfTimes: 3];
    [self validateConfigWasSavedToPersistenceNumberOfTimes: 1];
    UADSMetric *configFailureMetric = [self.deviceInfoTester configLatencyFailureMetricWithReason: kUADSConfigurationLoaderParsingError];
    UADSMetric *privacyFailureMetric = [self.deviceInfoTester privacyRequestFailureWithReason: kUADSPrivacyLoaderParsingError];
    [self validateMetrics: @[
         [privacyFailureMetric updatedWithValue: @(0)],
         self.deviceInfoTester.infoCollectionLatencyMetrics,
         self.deviceInfoTester.infoCompressionLatencyMetrics,
         [configFailureMetric updatedWithValue: @(0)],
         self.deviceInfoTester.emergencyOffMetrics,
    ]];
}

- (id<ISDKMetrics, ISDKPerformanceMetricsSender>)metricSender {
    return [UADSMetricSenderWithBatch decorateWithMetricSender: self.metricsSenderMock
                                  andConfigurationSubject: self.configCRUD
                                                andLogger: [UADSLoggerMock new]];
}

@end
