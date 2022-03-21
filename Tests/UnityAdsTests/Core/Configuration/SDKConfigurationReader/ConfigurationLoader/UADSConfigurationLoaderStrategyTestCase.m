#import <XCTest/XCTest.h>
#import "UADSConfigurationLoaderMock.h"
#import "UADSConfigurationLoaderStrategy.h"
#import "NSError+UADSError.h"
#import "SDKMetricsSenderMock.h"
#import "UADSTsiMetric.h"
#import "ConfigurationMetricTagsReaderMock.h"

@interface UADSConfigurationLoaderStrategyTestCase : XCTestCase
@property (nonatomic, strong) UADSConfigurationLoaderMock *mainLoaderMock;
@property (nonatomic, strong) UADSConfigurationLoaderMock *fallbackLoaderMock;
@property (nonatomic, strong) SDKMetricsSenderMock *metricSenderMock;
@property (nonatomic, strong) ConfigurationMetricTagsReaderMock *tagsReaderMock;
@end

@implementation UADSConfigurationLoaderStrategyTestCase

- (void)setUp {
    self.mainLoaderMock = [UADSConfigurationLoaderMock new];
    self.fallbackLoaderMock = [UADSConfigurationLoaderMock new];
    self.metricSenderMock = [SDKMetricsSenderMock new];
    self.tagsReaderMock = [ConfigurationMetricTagsReaderMock newWithExpectedTags: self.expectedTags];
}

- (id<UADSConfigurationLoader>)sut {
    return [UADSConfigurationLoaderStrategy newWithMainLoader: self.mainLoaderMock
                                            andFallbackLoader: self.fallbackLoaderMock
                                                 metricSender: self.metricSenderMock
                                             metricTagsReader: self.tagsReaderMock];
}

- (void)test_parse_error_calls_fallback {
    [self verifyFallbackIsCalledForLoaderError: uads_jsonParsingLoaderError(@{})];
}

- (void)test_request_not_created_error_calls_fallback {
    [self verifyFallbackIsCalledForLoaderError: uads_requestIsNotCreatedLoaderError];
}

- (void)test_loader_error_calls_fallback {
    [self verifyFallbackIsCalledForLoaderError: uads_invalidWebViewURLLoaderError];
}

- (void)test_response_code_error_calls_fallback {
    [self verifyFallbackIsCalledForLoaderError: uads_invalidResponseCodeError];
}

- (void)test_network_error_does_not_call_fallback {
    _mainLoaderMock.expectedError = [NSError errorWithDomain: @"network"
                                                        code: 500
                                                    userInfo: nil];

    _fallbackLoaderMock.expectedConfig = [USRVConfiguration newFromJSON: @{}];

    [self callSutWithErrorExpectation];
    XCTAssertEqual(_fallbackLoaderMock.loadCallCount, 0);
    XCTAssertEqualObjects(self.metricSenderMock.sentMetrics, @[]);
}

- (void)test_sends_metric_on_sucess_when_tkn_and_sid_not_set {
    _mainLoaderMock.expectedConfig = [USRVConfiguration newFromJSON: @{ }];

    [self callSutWithSuccessExpectation];
    NSArray *expected = @[ [UADSTsiMetric newMissingTokenWithTags: self.expectedTags], [UADSTsiMetric newMissingStateIdWithTags: self.expectedTags] ];

    XCTAssertEqualObjects(self.metricSenderMock.sentMetrics, expected);
}

- (void)test_doesn_not_send_metric_on_sucess_when_tkn_and_sid_set {
    _mainLoaderMock.expectedConfig = [USRVConfiguration newFromJSON: @{  @"tkn": @"1", @"sid": @"2" }];

    [self callSutWithSuccessExpectation];

    XCTAssertEqual(self.metricSenderMock.sentMetrics.count, 0);
}

- (void)callSutWithSuccessExpectation {
    XCTestExpectation *exp = self.defaultExpectation;

    id success = ^(id obj) {
        [exp fulfill];
    };

    id error = ^(NSError *error) {
        [exp fulfill];
        XCTFail("Should not return error for this flow");
    };


    [self.sut loadConfigurationWithSuccess: success
                        andErrorCompletion: error];

    [self waitForExpectations: @[exp]
                      timeout: 1];
}

- (void)callSutWithErrorExpectation {
    XCTestExpectation *exp = self.defaultExpectation;

    id success = ^(id obj) {
        XCTFail("Should not succeed for this flow");
        [exp fulfill];
    };

    id error = ^(NSError *error) {
        [exp fulfill];
    };


    [self.sut loadConfigurationWithSuccess: success
                        andErrorCompletion: error];

    [self waitForExpectations: @[exp]
                      timeout: 1];
}

- (void)verifyFallbackIsCalledForLoaderError: (NSError *)error {
    _mainLoaderMock.expectedError = error;

    _fallbackLoaderMock.expectedConfig = [USRVConfiguration newFromJSON: @{}];

    [self callSutWithSuccessExpectation];
    XCTAssertEqual(_fallbackLoaderMock.loadCallCount, 1);
    XCTAssertEqualObjects(self.metricSenderMock.sentMetrics, @[ [UADSTsiMetric newEmergencySwitchOffWithTags: self.expectedTags] ]);
}

- (XCTestExpectation *)defaultExpectation {
    return [self expectationWithDescription: @"strategy"];
}

- (NSDictionary *)expectedTags {
    return @{ @"tag": @"1" };
}

@end
