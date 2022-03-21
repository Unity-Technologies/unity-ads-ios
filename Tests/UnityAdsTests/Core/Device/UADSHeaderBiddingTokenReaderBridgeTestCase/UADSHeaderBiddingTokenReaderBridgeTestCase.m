#import <XCTest/XCTest.h>
#import "UADSHeaderBiddingTokenReaderBridgeTestCase.h"
#import "UADSHeaderBiddingTokenReaderBridge.h"
#import "UADSConfigurationReaderMock.h"
#import "UADSHeaderBiddingTokenAsyncReaderMock.h"
#import "UADSTokenStorage.h"
#import "XCTestCase+Convenience.h"
#import "UADSTools.h"

@interface UADSHeaderBiddingTokenReaderBridgeTestCase ()

@end

@implementation UADSHeaderBiddingTokenReaderBridgeTestCase

- (void)setUp {
    self.nativeGeneratorMock = [UADSHeaderBiddingTokenAsyncReaderMock new];
    self.tokenCRUDMock = [UADSTokenStorage new];
    self.configReaderMock = [UADSConfigurationReaderMock new];
}

- (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)sutWithNativeGeneration: (BOOL)tsi_nt {
    USRVConfiguration *config =  [USRVConfiguration new];

    config.experiments = [UADSConfigurationExperiments newWithJSON: @{
                              @"tsi_nt": @(tsi_nt).stringValue
    }];

    self.configReaderMock.expectedConfiguration = config;

    return [self createBridge];
}

- (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)createBridge {
    return [UADSHeaderBiddingTokenReaderBridge newWithNativeTokenGenerator: self.nativeGeneratorMock
                                                              andTokenCRUD: self.tokenCRUD
                                                    andConfigurationReader: self.configReaderMock];
}

- (void)test_if_native_generation_is_available_and_queue_is_empty_should_call_native_generator {
    NSString *expectedToken = @"token";

    self.nativeGeneratorMock.expectedToken = expectedToken;

    [self runTestWithNativeGeneration: true
                   withExpectedTokens: @[expectedToken]
             expectedGenerationCalled: 1
                            hbTimeout: 5
                      additionalBlock: nil];
}

- (void)test_if_tsi_nt_is_off_and_no_valid_token_in_storage_should_not_call_native_generation {
    NSPointerArray *array = [NSPointerArray new];

    [array addPointer: nil];
    [self runTestWithNativeGeneration: false
                   withExpectedTokens: (NSArray *)array
             expectedGenerationCalled: 0
                            hbTimeout: 1
                      additionalBlock: nil];
}

- (void)test_timeout_should_remove_a_listener {
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> sut = [self sutWithNativeGeneration: false];
    XCTestExpectation *expectation = self.defaultExpectation;
    NSString *expectedToken = @"token";

    expectation.expectedFulfillmentCount = 2;
    self.configReaderMock.expectedConfiguration.hbTokenTimeout = 1 * 1000;

    [sut getToken:^(NSString *_Nullable token, UADSTokenType type) {
        [expectation fulfill];
    }];

    [self waitForTimeInterval: 0.5];


    self.configReaderMock.expectedConfiguration.hbTokenTimeout = 5 * 1000;

    [sut getToken:^(NSString *_Nullable token, UADSTokenType type) {
        [expectation fulfill];

        XCTAssertEqualObjects(token, expectedToken);
        XCTAssertEqual(self.nativeGeneratorMock.getTokenCount, 0);
    }];


    [self waitForTimeInterval: 2];

    [sut createTokens: @[expectedToken]];
    [self waitForExpectations: @[expectation]
                      timeout: DEFAULT_WAITING_INTERVAL + 7];
}

- (void)test_if_tsi_nt_is_off_and_no_valid_token_in_storage_should_not_call_completion_before_timeout {
    id<UADSHeaderBiddingAsyncTokenReader> sut = [self sutWithNativeGeneration: false];
    XCTestExpectation *expectation = self.defaultExpectation;

    [expectation setInverted: true];
    NSInteger expectedTimeout = 5 * 1000;

    self.configReaderMock.expectedConfiguration.hbTokenTimeout = expectedTimeout;
    [sut getToken:^(NSString *_Nullable token, UADSTokenType type) {
        [expectation fulfill];
    }];
    [self waitForExpectations: @[expectation]
                      timeout: DEFAULT_WAITING_INTERVAL];
}

- (void)test_if_tsi_nt_on_and_created_queue_was_empty_should_generate_native_token {
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> sut = [self sutWithNativeGeneration: true];

    [sut createTokens: @[]];
    NSString *expectedToken = @"token";

    self.nativeGeneratorMock.expectedToken = expectedToken;
    [self runTestUsingCreatedSut: sut
              withExpectedTokens: @[expectedToken]
        expectedGenerationCalled: 1
                       hbTimeout: 1
                waitForHBTimeout: true
                 additionalBlock: nil];
}

- (void)test_if_tsi_nt_on_and_appended_queue_was_empty_should_generate_native_token {
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> sut = [self sutWithNativeGeneration: true];

    [sut appendTokens: @[]];
    NSString *expectedToken = @"token";

    self.nativeGeneratorMock.expectedToken = expectedToken;
    [self runTestUsingCreatedSut: sut
              withExpectedTokens: @[expectedToken]
        expectedGenerationCalled: 1
                       hbTimeout: 1
                waitForHBTimeout: true
                 additionalBlock: nil];
}

- (void)test_if_tsi_nt_on_and_init_token_was_nil_should_generate_native_token {
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> sut = [self sutWithNativeGeneration: true];

    [sut setInitToken: nil];
    NSString *expectedToken = @"token";

    self.nativeGeneratorMock.expectedToken = expectedToken;
    [self runTestUsingCreatedSut: sut
              withExpectedTokens: @[expectedToken]
        expectedGenerationCalled: 1
                       hbTimeout: 1
                waitForHBTimeout: true
                 additionalBlock: nil];
}

- (void)test_tsi_nt_off_should_notify_each_observer_with_its_own_token_after_queue_appended {
    NSArray *tokens = @[@"token1", @"token2", @"token3"];

    [self runTestWithNativeGeneration: false
                   withExpectedTokens: tokens
             expectedGenerationCalled: 0
                            hbTimeout: 5
                      additionalBlock:^(id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> sut) {
                          [sut appendTokens: tokens];
                      }];
}

- (void)test_tsi_nt_off_should_notify_each_observer_with_its_own_token_after_queue_created {
    NSArray *tokens = @[@"token1", @"token2", @"token3"];

    [self runTestWithNativeGeneration: false
                   withExpectedTokens: tokens
             expectedGenerationCalled: 0
                            hbTimeout: 5
                      additionalBlock:^(id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> sut) {
                          [sut createTokens: tokens];
                      }];
}

- (void)test_tsi_nt_off_should_notify_each_observer_with_init_token_when_its_saved {
    NSString *expectedToken = @"token";

    [self runTestWithNativeGeneration: false
                   withExpectedTokens: @[expectedToken, expectedToken, expectedToken]
             expectedGenerationCalled: 0
                            hbTimeout: 5
                      additionalBlock:^(id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> sut) {
                          [sut setInitToken: expectedToken];
                      }];
}

- (void)test_if_tsi_nt_is_off_and_storage_has_init_token_should_call_completion {
    NSString *expectedToken = @"token";

    [self.tokenCRUD setInitToken: expectedToken];
    [self runTestWithNativeGeneration: false
                   withExpectedTokens: @[expectedToken]
             expectedGenerationCalled: 0
                            hbTimeout: 0
                      additionalBlock: nil];
}

- (void)test_if_tsi_nt_is_on_and_storage_has_init_token_should_return_init_token {
    self.nativeGeneratorMock.expectedToken = @"token";
    NSString *initToken = @"init_token";
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> sut = [self sutWithNativeGeneration: true];

    [sut setInitToken: initToken];
    [self runTestUsingCreatedSut: sut
              withExpectedTokens: @[initToken]
        expectedGenerationCalled: 0
                       hbTimeout: 0
                waitForHBTimeout: false
                 additionalBlock: nil];
}

- (void)test_if_tsi_nt_is_on_and_storage_has_token_in_queue_should_return_token_from_queue {
    self.nativeGeneratorMock.expectedToken = @"token";
    NSString *expectedToken = @"expectedToken";
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> sut = [self sutWithNativeGeneration: true];

    [sut createTokens: @[expectedToken]];
    [self runTestUsingCreatedSut: sut
              withExpectedTokens: @[expectedToken]
        expectedGenerationCalled: 0
                       hbTimeout: 0
                waitForHBTimeout: false
                 additionalBlock: nil];
}

- (void)test_notifies_only_once_when_a_queue_is_created_tsi_nt_is_off {
    NSString *expectedToken = @"expectedToken";

    [self runTestWithNativeGeneration: false
                   withExpectedTokens: @[expectedToken]
             expectedGenerationCalled: 0
                            hbTimeout: 5
                      additionalBlock:^(id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> sut) {
                          [sut createTokens: @[expectedToken]];
                          [sut appendTokens: @[expectedToken]];
                      }];
}

- (void)test_if_a_queue_was_created_once_should_not_use_native_generator {
    NSString *expectedToken = @"token";
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> sut = [self sutWithNativeGeneration: true];

    [sut createTokens: @[expectedToken]];
    NSArray *array = @[
        expectedToken,
        [NSNull null]
    ];

    [self runTestUsingCreatedSut: sut
              withExpectedTokens: array
        expectedGenerationCalled: 0
                       hbTimeout: 5
                waitForHBTimeout: true
                 additionalBlock: nil];
}

- (void)test_if_the_queue_is_exhausted_dont_clean_the_queue_of_observers {
    NSString *expectedToken = @"token";
    NSString *expectedToken2 = @"token2";
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> sut = [self sutWithNativeGeneration: false];


    NSArray *array = @[
        expectedToken,
        expectedToken2
    ];

    [self runTestUsingCreatedSut: sut
              withExpectedTokens: array
        expectedGenerationCalled: 0
                       hbTimeout: 5
                waitForHBTimeout: false
                 additionalBlock:^(id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> currentSut) {
                     [sut createTokens: @[expectedToken]];
                     [currentSut appendTokens: @[expectedToken2]];
                 }];
}

- (void)test_if_tsi_nt_is_off_and_storage_has_token_in_queue_should_call_completion {
    NSString *expectedToken = @"token";
    id<UADSHeaderBiddingAsyncTokenReader> sut = [self sutWithNativeGeneration: false];
    XCTestExpectation *expectation = self.defaultExpectation;

    [self.tokenCRUD createTokens: @[expectedToken]];
    [sut getToken:^(NSString *_Nullable token, UADSTokenType type) {
        XCTAssertEqualObjects(token, expectedToken);
        XCTAssertEqual(self.nativeGeneratorMock.getTokenCount, 0);
        [expectation fulfill];
    }];
    [self waitForExpectations: @[expectation]
                      timeout: DEFAULT_WAITING_INTERVAL];
}

- (void)runTestWithNativeGeneration: (BOOL)nativeGeneration
                 withExpectedTokens: (NSArray<NSString *> *)expectedTokens
           expectedGenerationCalled: (NSInteger)generateCalled
                          hbTimeout: (NSInteger)timeout
                    additionalBlock: (SUTAdditionalBlock)block {
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> sut = [self sutWithNativeGeneration: nativeGeneration];

    [self runTestUsingCreatedSut: sut
              withExpectedTokens: expectedTokens
        expectedGenerationCalled: generateCalled
                       hbTimeout: timeout
                waitForHBTimeout: true
                 additionalBlock: block];
}

- (void)runTestUsingCreatedSut: (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)sut
            withExpectedTokens: (NSArray<NSString *> *)expectedTokens
      expectedGenerationCalled: (NSInteger)generateCalled
                     hbTimeout: (NSInteger)timeout
              waitForHBTimeout: (BOOL)waitForHBTimeout
               additionalBlock: (SUTAdditionalBlock)block {
    XCTestExpectation *expectation = self.defaultExpectation;


    _configReaderMock.expectedConfiguration.hbTokenTimeout = timeout * 1000;
    expectation.expectedFulfillmentCount = expectedTokens.count;

    for (NSString *expectedToken in expectedTokens) {
        [sut getToken:^(NSString *_Nullable token, UADSTokenType type) {
            NSString *tokenToCompare = [expectedToken isEqual: [NSNull null]] ? nil : expectedToken;
            XCTAssertEqualObjects(token, tokenToCompare);
            XCTAssertEqual(self.nativeGeneratorMock.getTokenCount, generateCalled);
            [expectation fulfill];
        }];
    }

    if (block) {
        block(sut);
    }

    NSInteger waitingTimeout = waitForHBTimeout ? DEFAULT_WAITING_INTERVAL + timeout : DEFAULT_WAITING_INTERVAL;

    [self waitForExpectations: @[expectation]
                      timeout: waitingTimeout];
}

- (id<UADSHeaderBiddingTokenCRUD>)tokenCRUD {
    return _tokenCRUDMock;
}

@end
