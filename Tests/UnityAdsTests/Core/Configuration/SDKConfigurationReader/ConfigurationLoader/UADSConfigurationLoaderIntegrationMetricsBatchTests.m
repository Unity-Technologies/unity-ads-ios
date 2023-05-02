
#import "UADSConfigurationLoaderIntegrationMetricsBatchTests.h"
#import "UADSMetricSenderWithBatch.h"
#import "UADSLoggerMock.h"
#import "XCTestCase+Convenience.h"

@interface UADSConfigurationLoaderIntegrationMetricsBatchTests ()
@property (nonatomic, strong) id<UADSConfigurationCRUD> configCRUD;
@end


@implementation UADSConfigurationLoaderIntegrationMetricsBatchTests

- (void)setUp {
    [super setUp];
    _configCRUD = [UADSConfigurationCRUDBase new];
    self.saverMock.original = _configCRUD;
}

- (void)test_config_failure_triggers_batcher_to_send_metrics_by_saving_empty_config {
    
    self.webRequestFactoryMock.expectedRequestData = @[[NSData new], [NSData new],  [NSData new]]; //privacy + config + fallback

    id sut = [self callSUTExpectingFailWithConfig:  [self factoryConfigWithExperiments: @{}]];
    [self.saverMock saveConfiguration: [USRVConfiguration newFromJSON: @{}]];
    XCTestExpectation *exp =  [self defaultExpectation];
    self.metricsSenderMock.exp = exp;
    [self waitForExpectations:@[exp] timeout: 1];
    [self validateCreatedRequestAtIndex: 0
                   withExpectedHostHame: self.expectedHostName
                     andExpectedQueries: nil];

    [self validateCreateRequestCalledNumberOfTimes: 2];
    [self validateConfigWasSavedToPersistenceNumberOfTimes: 1];
    UADSMetric *configFailureMetric = [self.deviceInfoTester configLatencyFailureMetricWithReason: kUADSConfigurationLoaderParsingError];
    UADSMetric *privacyFailureMetric = [self.deviceInfoTester privacyRequestFailureWithReason: kUADSPrivacyLoaderParsingError];
    [self validateMetrics: @[
         [privacyFailureMetric updatedWithValue: @(0)],
         self.deviceInfoTester.infoCollectionLatencyMetrics,
         self.deviceInfoTester.infoCompressionLatencyMetrics,
         [configFailureMetric updatedWithValue: @(0)]
    ]];
}

- (id<ISDKMetrics, ISDKPerformanceMetricsSender>)metricSender {
    return [UADSMetricSenderWithBatch decorateWithMetricSender: self.metricsSenderMock
                                  andConfigurationSubject: self.configCRUD
                                                andLogger: [UADSLoggerMock new]];
}

- (void)deleteConfigFile {
    NSString *fileName = [USRVSdkProperties getLocalConfigFilepath];

    [[NSFileManager defaultManager] removeItemAtPath: fileName
                                               error: nil];
}

@end
