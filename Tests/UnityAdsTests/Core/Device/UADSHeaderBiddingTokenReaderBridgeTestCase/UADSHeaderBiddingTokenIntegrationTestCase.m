#import "UADSHeaderBiddingTokenReaderBridgeTestCase.h"
#import <XCTest/XCTest.h>
#import "UADSHeaderBiddingTokenReaderBuilder.h"
#import "UADSDeviceReaderMock.h"
#import "SDKMetricsSenderMock.h"
#import "UADSTsiMetric.h"
#import "UADSConfigurationReaderMock.h"
#import "UnityAds.h"
#import "XCTestCase+Convenience.h"
#import "UADSPrivacyStorageMock.h"
#import "UADSServiceProvider.h"

@interface UADSHeaderBiddingTokenIntegrationTestCase : UADSHeaderBiddingTokenReaderBridgeTestCase
@property (nonatomic, strong) UADSHeaderBiddingTokenReaderBuilder *builder;
@property (nonatomic, strong) UADSDeviceReaderMock *readerMock;
@property (nonatomic, strong) SDKMetricsSenderMock *metricSenderMock;
@property (nonatomic, strong) UADSPrivacyStorage *privacyMock;
@end

@implementation UADSHeaderBiddingTokenIntegrationTestCase


- (void)setUp {
    [super setUp];
    [self deleteConfigFile];
    self.builder = [UADSHeaderBiddingTokenReaderBuilder new];
    self.readerMock = [UADSDeviceReaderMock new];
    self.readerMock.expectedInfo = @{ @"test": @"info" };
    self.metricSenderMock = [SDKMetricsSenderMock new];
    self.privacyMock = [UADSPrivacyStorage new];
    _builder.metricsSender = self.metricSenderMock;
    [self setInitState: INITIALIZED_SUCCESSFULLY];
    _builder.sdkConfigReader = self.configReaderMock;
    _builder.privacyStorage = self.privacyMock;
    _builder.tokenCRUD = [UADSTokenStorage new];
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

    [self runTestWithNativeGeneration: true
                   withExpectedTokens: @[UADSHeaderBiddingToken.newInvalidToken]
             expectedGenerationCalled: 0
                            hbTimeout: 0
                            initState: INITIALIZED_FAILED
                      additionalBlock: nil
                         privacyState: kUADSPrivacyResponseAllowed];
}

- (void)test_if_state_is_failed_return_null_token_even_if_queue_is_not_empty {
    [self.tokenCRUD createTokens: @[@"token"]];

    [self runTestWithNativeGeneration: true
                   withExpectedTokens: @[UADSHeaderBiddingToken.newInvalidToken]
             expectedGenerationCalled: 0
                            hbTimeout: 0
                            initState: INITIALIZED_FAILED
                      additionalBlock: nil
                         privacyState: kUADSPrivacyResponseDenied];
    [self validateMetricsSent: @[[self nullTokenMetricWithState: INITIALIZED_FAILED
                                                           type: kUADSTokenRemote]]];
}

- (void)test_if_state_is_not_initialized_return_null_token_even_if_first_init_token_is_not_nil {
    [self.tokenCRUD setInitToken: @"init_token"];

    [self runTestWithNativeGeneration: true
                   withExpectedTokens: @[UADSHeaderBiddingToken.newInvalidToken]
             expectedGenerationCalled: 0
                            hbTimeout: 0
                            initState: NOT_INITIALIZED
                      additionalBlock: nil
                         privacyState: kUADSPrivacyResponseUnknown];
}

- (void)test_if_state_is_not_initialized_return_null_token_even_if_queue_is_not_empty {
    [self.tokenCRUD createTokens: @[@"token"]];

    [self runTestWithNativeGeneration: true
                   withExpectedTokens: @[UADSHeaderBiddingToken.newInvalidToken]
             expectedGenerationCalled: 0
                            hbTimeout: 0
                            initState: NOT_INITIALIZED
                      additionalBlock: nil
                         privacyState: kUADSPrivacyResponseDenied];
    [self validateMetricsSent: @[[self nullTokenMetricWithState: NOT_INITIALIZED
                                                           type: kUADSTokenRemote]]];
}

- (void)test_adds_prefix_to_native_generated_token {
    self.nativeGeneratorMock = nil;
    self.builder.deviceInfoReader = self.readerMock;
    // encoded device info: @{ @"test": @"info" };
    NSString *tokenString = @"1:H4sIAAAAAAAAE6tWKkktLlGyUsrMS8tXqgUAIuq+TA8AAAA=";

    UADSHeaderBiddingToken *token = [UADSHeaderBiddingToken newNative:tokenString];
    
    [self runTestWithNativeGeneration: true
                   withExpectedTokens: @[token]
             expectedGenerationCalled: 0
                            hbTimeout: 1
                            initState: INITIALIZED_SUCCESSFULLY
                      additionalBlock: nil
                         privacyState: kUADSPrivacyResponseAllowed];
    [self validateMetricsSent: @[self.infoCompressionLatencyMetrics,
                                 [self nativeTokenGeneratedMetricWithState: INITIALIZED_SUCCESSFULLY]]];
}

- (void)test_sends_null_token_metric_when_timeout {

    [self runTestWithNativeGeneration: false
                   withExpectedTokens: @[UADSHeaderBiddingToken.newInvalidToken]
             expectedGenerationCalled: 0
                            hbTimeout: 1
                            initState: INITIALIZING
                      additionalBlock: nil
                         privacyState: kUADSPrivacyResponseUnknown];
    [self validateMetricsSent: @[[self nullTokenMetricWithState: INITIALIZING
                                                           type: kUADSTokenRemote]]];
}

- (void)test_returns_native_token_during_initializing_state {
    UADSHeaderBiddingToken *expectedToken = [UADSHeaderBiddingToken newNative: @"expectedToken"];

    self.nativeGeneratorMock.expectedToken = expectedToken.value;
    [self runTestWithNativeGeneration: true
                   withExpectedTokens: @[expectedToken]
             expectedGenerationCalled: 1
                            hbTimeout: 1
                            initState: INITIALIZING
                      additionalBlock: nil
                         privacyState: kUADSPrivacyResponseUnknown];
    [self validateMetricsSent: @[[self nativeTokenGeneratedMetricWithState: INITIALIZING]]];
}

- (void)test_available_async_token_sent_when_return_valid_token {
    UADSHeaderBiddingToken *token = [UADSHeaderBiddingToken newWebToken: @"token"];
    
    UADSMetric *expectedMetric = [UADSTsiMetric newAsyncTokenTokenAvailableWithTags: [self metricTagsWithState: INITIALIZED_SUCCESSFULLY]];

    [self.tokenCRUD createTokens: @[token.value]];
    [self runTestWithNativeGeneration: false
                   withExpectedTokens: @[token]
             expectedGenerationCalled: 0
                            hbTimeout: 1
                            initState: INITIALIZED_SUCCESSFULLY
                      additionalBlock: nil
                         privacyState: kUADSPrivacyResponseUnknown];
    [self validateMetricsSent: @[expectedMetric]];
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
                      additionalBlock: nil
                         privacyState: kUADSPrivacyResponseAllowed];
    [self validateMetricsSent: @[[self nullTokenMetricWithState: INITIALIZED_SUCCESSFULLY
                                                           type: kUADSTokenNative]]];
}

- (void)test_native_token_generation_timeout_when_privacy_is_not_resolved {
    id sut = [self sutWithNativeGeneration: true
                            andPrivacyWait: true
                                andTimeout: 4];

    UADSHeaderBiddingToken *expectedToken = [UADSHeaderBiddingToken newNative: @"expectedToken"];

    self.nativeGeneratorMock.expectedToken = expectedToken.value;
    [self setInitState: INITIALIZED_SUCCESSFULLY];

    [self runTestUsingCreatedSut: sut
              withExpectedTokens: @[expectedToken]
        expectedGenerationCalled: 1
                       hbTimeout: 5
                waitForHBTimeout: true
                 additionalBlock: nil];

    UADSMetric *expectedMetric = [self nativeTokenGeneratedMetricWithState: INITIALIZED_SUCCESSFULLY];

    [self validateMetricsSent: @[expectedMetric]];
}

- (void)test_native_token_generation_timeout_removes_observers {
    id sut = [self sutWithNativeGeneration: true
                            andPrivacyWait: true
                                andTimeout: 4];

    UADSHeaderBiddingToken *expectedToken = [UADSHeaderBiddingToken newNative: @"expectedToken"];

    self.nativeGeneratorMock.expectedToken = expectedToken.value;
    [self setInitState: INITIALIZED_SUCCESSFULLY];

    [self runTestUsingCreatedSut: sut
              withExpectedTokens: @[expectedToken]
        expectedGenerationCalled: 1
                       hbTimeout: 5
                waitForHBTimeout: true
                 additionalBlock: nil];

    // trigger save after timeout to validate that a subscriber is removed
    [self.builder.privacyStorage saveResponse: [UADSInitializationResponse new]];
    [self waitForTimeInterval: 1];

    UADSMetric *expectedMetric = [self nativeTokenGeneratedMetricWithState: INITIALIZED_SUCCESSFULLY];

    XCTAssertEqual(self.nativeGeneratorMock.getTokenCount, 1);
    [self validateMetricsSent: @[expectedMetric]];
}

- (void)test_native_token_generation_returns_token_when_privacy_is_denied {
    id sut = [self sutWithNativeGeneration: true
                            andPrivacyWait: true
                                andTimeout: 4];

    UADSHeaderBiddingToken *expectedToken = [UADSHeaderBiddingToken newNative: @"expectedToken"];

    self.nativeGeneratorMock.expectedToken = expectedToken.value;
    [self setInitState: INITIALIZED_SUCCESSFULLY];
    [self setPrivacyState: kUADSPrivacyResponseDenied];
    
  
    [self runTestUsingCreatedSut: sut
              withExpectedTokens: @[expectedToken]
        expectedGenerationCalled: 1
                       hbTimeout: 5
                waitForHBTimeout: true
                 additionalBlock: nil];


    UADSMetric *expectedMetric = [self nativeTokenGeneratedMetricWithState: INITIALIZED_SUCCESSFULLY];

    [self validateMetricsSent: @[expectedMetric]];
}

- (void)test_native_token_generation_returns_token_when_privacy_is_resolved_after_token_requested {
    NSInteger waitForPrivacy = 4;
    id sut = [self sutWithNativeGeneration: true
                            andPrivacyWait: true
                                andTimeout: waitForPrivacy];

    NSString *expectedToken = @"expectedToken";

    self.nativeGeneratorMock.expectedToken = expectedToken;
    [self setInitState: INITIALIZED_SUCCESSFULLY];


    XCTestExpectation *expectation = self.defaultExpectation;

    [sut getToken:^(UADSHeaderBiddingToken *_Nullable token) {
        NSString *tokenToCompare = [expectedToken isEqual: [NSNull null]] ? nil : expectedToken;
        XCTAssertEqualObjects(token.value, tokenToCompare);
        XCTAssertEqual(self.nativeGeneratorMock.getTokenCount, 1);
        [expectation fulfill];
    }];

    UADSInitializationResponse *response = [UADSInitializationResponse new];

    response.allowTracking = true;
    [self.builder.privacyStorage saveResponse: response];

    [self waitForExpectations: @[expectation]
                      timeout: waitForPrivacy];


    UADSMetric *expectedMetric = [self nativeTokenGeneratedMetricWithState: INITIALIZED_SUCCESSFULLY];

    [self validateMetricsSent: @[expectedMetric]];
}

- (void)test_native_token_generation_returns_token_when_privacy_is_allowed {
    id sut = [self sutWithNativeGeneration: true
                            andPrivacyWait: true
                                andTimeout: 4];

    UADSHeaderBiddingToken *expectedToken = [UADSHeaderBiddingToken newNative: @"expectedToken"];

    self.nativeGeneratorMock.expectedToken = expectedToken.value;
    [self setInitState: INITIALIZED_SUCCESSFULLY];
    [self setPrivacyState: kUADSPrivacyResponseAllowed];

    [self runTestUsingCreatedSut: sut
              withExpectedTokens: @[expectedToken]
        expectedGenerationCalled: 1
                       hbTimeout: 5
                waitForHBTimeout: true
                 additionalBlock: nil];


    UADSMetric *expectedMetric = [self nativeTokenGeneratedMetricWithState: INITIALIZED_SUCCESSFULLY];

    [self validateMetricsSent: @[expectedMetric]];
}

- (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)sutWithNativeGeneration: (BOOL)tsi_nt
                                                                              andPrivacyWait: (BOOL)tsi_prw
                                                                                  andTimeout: (NSInteger)privacyTimeout {
    USRVConfiguration *config =  [USRVConfiguration new];

    config.experiments = [UADSConfigurationExperiments newWithJSON: @{
                              @"tsi_nt": @(tsi_nt).stringValue,
                              @"tsi_prw": @(tsi_prw).stringValue
    }];
    config.privacyWaitTimeout = privacyTimeout * 1000;
    self.configReaderMock.expectedConfiguration = config;

    return [self createBridge];
}

- (void)runTestWithNativeGeneration: (BOOL)nativeGeneration
                 withExpectedTokens: (NSArray<UADSHeaderBiddingToken *> *)expectedTokens
           expectedGenerationCalled: (NSInteger)generateCalled
                          hbTimeout: (NSInteger)timeout
                          initState: (InitializationState)state
                    additionalBlock: (SUTAdditionalBlock)block
                       privacyState: (UADSPrivacyResponseState)privacyState {
    [self setInitState: state];
    [self setPrivacyState: privacyState];
    [self runTestWithNativeGeneration: nativeGeneration
                   withExpectedTokens: expectedTokens
             expectedGenerationCalled: generateCalled
                            hbTimeout: timeout
                      additionalBlock: nil];
}

- (void)setInitState: (InitializationState)state {
    [USRVSdkProperties setInitializationState: state];
}

- (void)setPrivacyState: (UADSPrivacyResponseState)state {
    UADSInitializationResponse *response = nil;

    switch (state) {
        case kUADSPrivacyResponseUnknown:
            break;

        case kUADSPrivacyResponseAllowed:
            response = [UADSInitializationResponse newFromDictionary: @{ @"pas": @(true) }];
            response.responseCode = 200;
            break;

        case kUADSPrivacyResponseDenied:
            response = [UADSInitializationResponse newFromDictionary: @{ @"pas": @(false) }];
            break;
    }
    [self.privacyMock saveResponse: response];
}

- (void)validateMetricsSent: (NSArray *)expected {
    XCTAssertEqualObjects(self.metricSenderMock.sentMetrics, expected);
}

- (UADSMetric *)nativeTokenGeneratedMetricWithState: (InitializationState)state {
    return [UADSTsiMetric newNativeGeneratedTokenAvailableWithTags: [self metricTagsWithState: state]];
}

- (UADSMetric *)infoCompressionLatencyMetrics {
    return [UADSTsiMetric newDeviceInfoCompressionLatency: @(0)];
}

- (UADSMetric *)nullTokenMetricWithState: (InitializationState)state type: (UADSTokenType)type  {
    NSDictionary *tags = [self metricTagsWithState: state];

    return type == kUADSTokenRemote ? [UADSTsiMetric newAsyncTokenNullWithTags: tags] : [UADSTsiMetric newNativeGeneratedTokenNullWithTags: tags];
}

- (NSDictionary *)metricTagsWithState: (InitializationState)state {
    NSMutableDictionary *tags = [NSMutableDictionary dictionary];

    tags[@"state"] = UADSStringFromInitializationState(state);
    return tags;
}

- (void)test_multithread_native_generation_does_not_crash {
    [self mockSuccessInitWithNativeGenerationOn: true];
    UADSServiceProvider *sut = [UADSServiceProvider new];
    [self asyncExecuteTimes: 1000
                      block:^(XCTestExpectation *_Nonnull expectation, int index) {
                            [sut.hbTokenReader getToken:^(UADSHeaderBiddingToken * _Nullable token) {
                                XCTAssertTrue([token.value hasPrefix: @"1:"]);
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
    config.sdkVersion = @"123";
    config.webViewHash = @"hash";
    config.webViewVersion = @"123";
    config.metricsUrl = @"url";
    [self saveConfigToFile: config];
//    [[[UADSServiceProvider sharedInstance] configurationSaver] saveConfiguration: config];
}

- (void)saveConfigToFile: (USRVConfiguration *)config {
    [config saveToDisk];
}
- (void)deleteConfigFile {
    NSString *fileName = [USRVSdkProperties getLocalConfigFilepath];

    [[NSFileManager defaultManager] removeItemAtPath: fileName
                                               error: nil];
}
@end
