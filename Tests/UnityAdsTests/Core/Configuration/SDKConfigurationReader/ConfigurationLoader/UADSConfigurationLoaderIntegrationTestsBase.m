#import "UADSConfigurationLoaderIntegrationTestsBase.h"
#import "NSDictionary+JSONString.h"
#import "XCTestCase+Convenience.h"
#import "NSData+JSONSerialization.h"
#import "NSData+GZIP.h"
#import "UADSCurrentTimestampMock.h"
#import "UADSRetryInfoReaderMock.h"

@implementation UADSConfigurationLoaderIntegrationTestsBase

- (void)setUp {
    _webRequestFactoryMock = [WebRequestFactoryMock new];
    _saverMock = [UADSConfigurationPersistenceMock new];
    _metricsSenderMock = [SDKMetricsSenderMock new];
    _helper = [UADSLoaderIntegrationTestsHelper new];
    _deviceInfoTester = [UADSDeviceTestsHelper new];
    _privacyStorage = [UADSPrivacyStorage new];
    [_deviceInfoTester clearAllStorages];
}

- (id<UADSConfigurationSaver>)configSaver {
    return _saverMock;
}

- (id<ISDKMetrics, ISDKPerformanceMetricsSender>)metricSender {
    return _metricsSenderMock;
}

- (void)validateMetrics: (NSArray<UADSMetric *> *)expectedMetrics {
    XCTAssertEqualObjects(_metricsSenderMock.sentMetrics,
                          expectedMetrics);
}

- (id<UADSConfigurationLoader>)sutForConfig: (UADSConfigurationLoaderBuilderConfig)config {
    return [self sutBuilderForConfig: config].loader;
}

- (void)validateCreatedRequestAtIndex: (NSInteger)index
                 withExpectedHostHame: (NSString *)hostName
                      andBodyDataKeys: (NSArray<NSString *> *)bodyDataKeys {
    [self validateCreatedRequestAtIndex: index
                   withExpectedHostHame: hostName
                     andExpectedQueries: nil
                        andBodyDataKeys: bodyDataKeys];
}

- (void)validateCreatedRequestAtIndex: (NSInteger)index
                 withExpectedHostHame: (NSString *)hostName
                   andExpectedQueries: (NSDictionary *)queryAttributes
                      andBodyDataKeys: (NSArray<NSString *> *)bodyDataKeys {
    WebRequestMock *request = _webRequestFactoryMock.createdRequests[index];

    [_helper validateURLofRequest: request.url
             withExpectedHostHame: hostName
               andExpectedQueries: queryAttributes];
    [self validateGzipBodyContainsKeys: request.bodyData
                          expectedKeys: bodyDataKeys];
}

- (void)validateCreatedRequestAtIndex: (NSInteger)index
                 withExpectedHostHame: (NSString *)hostName
                   andExpectedQueries: (NSDictionary *)queryAttributes {
    WebRequestMock *request = _webRequestFactoryMock.createdRequests[index];

    [_helper validateURLofRequest: request.url
             withExpectedHostHame: hostName
               andExpectedQueries: queryAttributes];
}

- (void)validateCreatedRequestAtIndex: (NSInteger)index
           withExpectedCompressedKeys: (NSArray *)keys {
    WebRequestMock *request = _webRequestFactoryMock.createdRequests[index];

    [_helper  validateURLOfRequest: request.url
        withExpectedCompressedKeys: keys];
}

- (void)validateCreateRequestCalledNumberOfTimes: (NSInteger)count {
    XCTAssertEqual(_webRequestFactoryMock.createdRequests.count, count);
}

- (void)validateConfigWasSavedToPersistenceNumberOfTimes: (NSInteger)count {
    XCTAssertEqual(_saverMock.receivedConfig.count, count);
}

- (UADSConfigurationRequestFactoryConfigBase *)factoryConfigWithExperiments: (NSDictionary *)experiments {
    return [UADSConfigurationRequestFactoryConfigBase defaultWithExperiments: [UADSConfigurationExperiments newWithJSON: experiments]];
}

- (NSString *)expectedHostName {
    return [kDefaultConfigVersion stringByAppendingFormat: @".%@", kDefaultConfigHostNameBase];
}

- (UADSConfigurationLoaderBuilder *)sutBuilderForConfig: (UADSConfigurationLoaderBuilderConfig)config {
    UADSConfigurationLoaderBuilder *builder = [UADSConfigurationLoaderBuilder newWithConfig: config
                                                                       andWebRequestFactory      : _webRequestFactoryMock metricSender: self.metricSender];

    builder.configurationSaver = self.configSaver;
    builder.privacyStorage = _privacyStorage;
    builder.currentTimeStampReader = [UADSCurrentTimestampMock new];
    builder.retryInfoReader = [UADSRetryInfoReaderMock newWithInfo: _deviceInfoTester.retryTags];

    return builder;
}

- (void)callSUTExpectingFailWithConfig: (UADSConfigurationLoaderBuilderConfig)config {
    id<UADSConfigurationLoader> sut = [self sutForConfig: config];
    XCTestExpectation *exp = self.defaultExpectation;
    id success = ^(id obj) {
        XCTFail(@"Should not succeed");
        [exp fulfill];
    };

    id error = ^(id<UADSError> error) {
        [exp fulfill];
    };

    [sut loadConfigurationWithSuccess: success
                   andErrorCompletion: error];

    [self waitForExpectations: @[exp]
                      timeout: 1];
}

- (void)callSUTExpectingSuccessWithConfig: (UADSConfigurationLoaderBuilderConfig)config {
    id<UADSConfigurationLoader> sut = [self sutForConfig: config];

    [self callSUTExpectingSuccess: sut];
}

- (void)callSUTExpectingSuccess:  (id<UADSConfigurationLoader>)sut {
    XCTestExpectation *exp = self.defaultExpectation;
    id success = ^(id obj) {
        [exp fulfill];
    };

    id error = ^(id<UADSError> error) {
        XCTFail(@"Should not fail");
        [exp fulfill];
    };

    [sut loadConfigurationWithSuccess: success
                   andErrorCompletion: error];

    [self waitForExpectations: @[exp]
                      timeout: 1];
}

- (void)validateGzipBodyContainsKeys: (NSData *)body expectedKeys: (NSArray<NSString *> *)expectedKeys {
    NSDictionary *dictionay = [[body uads_gunzippedData] uads_jsonRepresentation];

    [self.deviceInfoTester validateDataContains: dictionay
                                        allKeys: expectedKeys];
}

- (NSArray<NSString *> *)appendCommonKeys: (NSArray<NSString *> *)array {
    return [array arrayByAddingObjectsFromArray: @[
                @"callType",
                @"sdkVersionName"
    ]];
}

@end
