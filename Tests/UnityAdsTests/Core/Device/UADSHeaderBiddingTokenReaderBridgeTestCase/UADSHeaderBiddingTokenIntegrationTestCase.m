#import "UADSHeaderBiddingTokenReaderBridgeTestCase.h"
#import <XCTest/XCTest.h>
#import "UADSHeaderBiddingTokenReaderBuilder.h"
#import "UADSDeviceReaderMock.h"
#import "SDKMetricsSenderMock.h"
#import "UADSTsiMetric.h"
#import "UADSConfigurationReaderMock.h"
#import "UnityAds.h"
#import "XCTestCase+Convenience.h"

@interface UADSHeaderBiddingTokenIntegrationTestCase : UADSHeaderBiddingTokenReaderBridgeTestCase
@property (nonatomic, strong) UADSHeaderBiddingTokenReaderBuilder *builder;
@property (nonatomic, strong) UADSDeviceReaderMock *readerMock;
@property (nonatomic, strong) SDKMetricsSenderMock *metricSenderMock;
@end

@implementation UADSHeaderBiddingTokenIntegrationTestCase


- (void)setUp {
    [super setUp];
    self.builder = [UADSHeaderBiddingTokenReaderBuilder new];
    self.readerMock = [UADSDeviceReaderMock new];
    self.readerMock.expectedInfo = @{ @"test": @"info" };
    self.metricSenderMock = [SDKMetricsSenderMock new];
    _builder.metricsSender = self.metricSenderMock;
    self.configReaderMock.experiments = [self tags];
    [self setInitState: INITIALIZED_SUCCESSFULLY];
    [[UADSTokenStorage sharedInstance] deleteTokens];
    [[UADSTokenStorage sharedInstance] setInitToken: nil];
    _builder.sdkConfigReader = self.configReaderMock;
}

- (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)createBridge {
    _builder.tokenGenerator = self.nativeGeneratorMock;
    return _builder.defaultReader;
}

- (id<UADSHeaderBiddingTokenCRUD>)tokenCRUD {
    return _builder.defaultReader;
}

- (void)test_if_state_is_failed_should_return_null_token_even_if_first_init_token_is_not_nil {
    [self.tokenCRUD setInitToken: @"init_token"];
    NSPointerArray *array = [NSPointerArray new];

    [array addPointer: nil];
    [self runTestWithNativeGeneration: true
                   withExpectedTokens: (NSArray *)array
             expectedGenerationCalled: 0
                            hbTimeout: 0
                            initState: INITIALIZED_FAILED
                      additionalBlock: nil];
}

- (void)test_if_state_is_failed_return_null_token_even_if_queue_is_not_empty {
    [self.tokenCRUD createTokens: @[@"token"]];
    NSPointerArray *array = [NSPointerArray new];

    [array addPointer: nil];
    [self runTestWithNativeGeneration: true
                   withExpectedTokens: (NSArray *)array
             expectedGenerationCalled: 0
                            hbTimeout: 0
                            initState: INITIALIZED_FAILED
                      additionalBlock: nil];
    [self validateMetricsSent: @[[self nullTokenMetricWithState: INITIALIZED_FAILED
                                                           type: kUADSTokenRemote]]];
}

- (void)test_if_state_is_not_initialized_return_null_token_even_if_first_init_token_is_not_nil {
    [self.tokenCRUD setInitToken: @"init_token"];
    NSPointerArray *array = [NSPointerArray new];

    [array addPointer: nil];
    [self runTestWithNativeGeneration: true
                   withExpectedTokens: (NSArray *)array
             expectedGenerationCalled: 0
                            hbTimeout: 0
                            initState: NOT_INITIALIZED
                      additionalBlock: nil];
}

- (void)test_if_state_is_not_initialized_return_null_token_even_if_queue_is_not_empty {
    [self.tokenCRUD createTokens: @[@"token"]];
    NSPointerArray *array = [NSPointerArray new];

    [array addPointer: nil];
    [self runTestWithNativeGeneration: true
                   withExpectedTokens: (NSArray *)array
             expectedGenerationCalled: 0
                            hbTimeout: 0
                            initState: NOT_INITIALIZED
                      additionalBlock: nil];
    [self validateMetricsSent: @[[self nullTokenMetricWithState: NOT_INITIALIZED
                                                           type: kUADSTokenRemote]]];
}

- (void)test_adds_prefix_to_native_generated_token {
    self.nativeGeneratorMock = nil;
    self.builder.deviceInfoReader = self.readerMock;
    // encoded device info: @{ @"test": @"info" };
    NSString *token = @"1:H4sIAAAAAAAAE6tWKkktLlGyUsrMS8tXqgUAIuq+TA8AAAA=";

    [self runTestWithNativeGeneration: true
                   withExpectedTokens: @[token]
             expectedGenerationCalled: 0
                            hbTimeout: 1
                            initState: INITIALIZED_SUCCESSFULLY
                      additionalBlock: nil];
    [self validateMetricsSent: @[self.infoCompressionLatencyMetrics,
                                 [self nativeTokenGeneratedMetricWithState: INITIALIZED_SUCCESSFULLY]]];
}

- (void)test_sends_null_token_metric_when_timeout {
    NSPointerArray *array = [NSPointerArray new];

    [array addPointer: nil];
    [self runTestWithNativeGeneration: false
                   withExpectedTokens: (NSArray *)array
             expectedGenerationCalled: 0
                            hbTimeout: 1
                            initState: INITIALIZING
                      additionalBlock: nil];
    [self validateMetricsSent: @[[self nullTokenMetricWithState: INITIALIZING
                                                           type: kUADSTokenRemote]]];
}

- (void)test_no_metric_send_when_return_valid_token {
    NSArray *expected = @[@"token"];

    [self.tokenCRUD createTokens: expected];
    [self runTestWithNativeGeneration: false
                   withExpectedTokens: expected
             expectedGenerationCalled: 0
                            hbTimeout: 1
                            initState: INITIALIZED_SUCCESSFULLY
                      additionalBlock: nil];
    [self validateMetricsSent: @[]];
}

- (void)test_calls_timeout_completion_if_native_generation_is_too_long {
    self.nativeGeneratorMock.shoudSkipCompletion = true;

    NSPointerArray *array = [NSPointerArray new];

    [array addPointer: nil];
    [self runTestWithNativeGeneration: true
                   withExpectedTokens: (NSArray *)array
             expectedGenerationCalled: 1
                            hbTimeout: 1
                            initState: INITIALIZED_SUCCESSFULLY
                      additionalBlock: nil];
    [self validateMetricsSent: @[[self nullTokenMetricWithState: INITIALIZED_SUCCESSFULLY
                                                           type: kUADSTokenNative]]];
}

- (void)runTestWithNativeGeneration: (BOOL)nativeGeneration
                 withExpectedTokens: (NSArray<NSString *> *)expectedTokens
           expectedGenerationCalled: (NSInteger)generateCalled
                          hbTimeout: (NSInteger)timeout
                          initState: (InitializationState)state
                    additionalBlock: (SUTAdditionalBlock)block {
    [self setInitState: state];
    [self runTestWithNativeGeneration: nativeGeneration
                   withExpectedTokens: expectedTokens
             expectedGenerationCalled: generateCalled
                            hbTimeout: timeout
                      additionalBlock: nil];
}

- (void)setInitState: (InitializationState)state {
    [USRVSdkProperties setInitializationState: state];
}

- (void)validateMetricsSent: (NSArray *)expected {
    XCTAssertEqualObjects(self.metricSenderMock.sentMetrics, expected);
}

- (UADSMetric *)nativeTokenGeneratedMetricWithState: (InitializationState)state {
    return [UADSTsiMetric newNativeGeneratedTokenAvailableWithTags: [self metricTagsWithState: state]];
}

- (UADSMetric *)infoCompressionLatencyMetrics {
    return [UADSTsiMetric newDeviceInfoCompressionLatency: @(0)
                                                 withTags: self.tags];
}

- (UADSMetric *)nullTokenMetricWithState: (InitializationState)state type: (UADSTokenType)type {
    NSDictionary *tags = [self metricTagsWithState: state];

    return type == kUADSTokenRemote ? [UADSTsiMetric newAsyncTokenNullWithTags: tags] : [UADSTsiMetric newNativeGeneratedTokenNullWithTags: tags];
}

- (NSDictionary *)metricTagsWithState: (InitializationState)state {
    NSMutableDictionary *tags = [NSMutableDictionary dictionaryWithDictionary: self.tags];

    tags[@"state"] = UADSStringFromInitializationState(state);
    return tags;
}

- (NSDictionary *)tags {
    return @{ @"1": @"tag" };
}

- (void)test_multithread_native_generation_does_not_crash {
    [self mockSuccessInitWithNativeGenerationOn: true];


    [self asyncExecuteTimes: 1000
                      block:^(XCTestExpectation *_Nonnull expectation, int index) {
                          [UnityAds getToken:^(NSString *_Nullable token) {
                              XCTAssertTrue([token hasPrefix: @"1:"]);
                              [expectation fulfill];
                          }];
                      }];
}

- (void)mockSuccessInitWithNativeGenerationOn: (BOOL)ntOn {
    [USRVSdkProperties setInitializationState: INITIALIZED_SUCCESSFULLY];
    USRVConfiguration *config =  [USRVConfiguration new];

    config.webViewUrl = @"url";
    config.experiments = [UADSConfigurationExperiments newWithJSON: @{
                              @"tsi_nt": @(ntOn).stringValue
    }];
    [config saveToDisk];
}

@end
