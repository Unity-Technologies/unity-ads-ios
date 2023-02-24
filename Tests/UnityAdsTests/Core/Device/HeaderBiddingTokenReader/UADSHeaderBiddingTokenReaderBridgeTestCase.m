#import <XCTest/XCTest.h>
#import "UADSHeaderBiddingTokenReaderBridgeTestCase.h"
#import "UADSHeaderBiddingTokenReaderBridge.h"
#import "UADSConfigurationReaderMock.h"
#import "UADSHeaderBiddingTokenAsyncReaderMock.h"
#import "UADSTokenStorage.h"
#import "XCTestCase+Convenience.h"
#import "UADSTools.h"
#import "NSArray+Map.h"

@interface UADSHeaderBiddingTokenReaderBridgeTestCase ()

@end

@implementation UADSHeaderBiddingTokenReaderBridgeTestCase

- (void)setUp {
    self.nativeGeneratorMock = [UADSHeaderBiddingTokenAsyncReaderMock new];
    self.tokenCRUDMock = [UADSTokenStorage new];
    self.configReaderMock = [UADSConfigurationReaderMock new];
}

- (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)sut {
    return [self sutWithTimeoutValue: 5];
}

- (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)sutWithTimeoutValue: (NSInteger)hbTimeout {
    USRVConfiguration *config =  [USRVConfiguration new];
    config.hbTokenTimeout = hbTimeout * 1000;
    self.configReaderMock.expectedConfiguration = config;

    return [self createBridge];
}

- (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)createBridge {
    return [UADSHeaderBiddingTokenReaderBridge newWithNativeTokenGenerator: self.nativeGeneratorMock
                                                              andTokenCRUD: self.tokenCRUD
                                                    andConfigurationReader: self.configReaderMock];
}

- (void)test_if_native_generation_is_available_and_queue_is_empty_should_call_native_generator {
    UADSHeaderBiddingToken *expectedToken = [UADSHeaderBiddingToken newNative: @"token"];

    self.nativeGeneratorMock.expectedToken = expectedToken.value;

    [self runTestWithExpectedTokens: @[expectedToken]
             expectedGenerationCalled: 1
                            hbTimeout: 5
                      additionalBlock: nil];
}

- (void)test_if_tsi_nt_on_and_created_queue_was_empty_should_generate_native_token {
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> sut = [self sut];

    [sut createTokens: @[]];
    UADSHeaderBiddingToken *expectedToken = [UADSHeaderBiddingToken newNative: @"token"];

    self.nativeGeneratorMock.expectedToken = expectedToken.value;
    [self runTestUsingCreatedSut: sut
              withExpectedTokens: @[expectedToken]
        expectedGenerationCalled: 1
                       hbTimeout: 100
                waitForHBTimeout: true
                 additionalBlock: nil];
}

- (void)test_if_tsi_nt_on_and_appended_queue_was_empty_should_generate_native_token {
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> sut = [self sut];

    [sut appendTokens: @[]];
    UADSHeaderBiddingToken *expectedToken = [UADSHeaderBiddingToken newNative: @"token"];

    self.nativeGeneratorMock.expectedToken = expectedToken.value;
    [self runTestUsingCreatedSut: sut
              withExpectedTokens: @[expectedToken]
        expectedGenerationCalled: 1
                       hbTimeout: 1
                waitForHBTimeout: true
                 additionalBlock: nil];
}

- (void)test_if_tsi_nt_on_and_init_token_was_nil_should_generate_native_token {
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> sut = [self sut];

    [sut setInitToken: nil];
    UADSHeaderBiddingToken *expectedToken = [UADSHeaderBiddingToken newNative: @"token"];

    self.nativeGeneratorMock.expectedToken = expectedToken.value;
    [self runTestUsingCreatedSut: sut
              withExpectedTokens: @[expectedToken]
        expectedGenerationCalled: 1
                       hbTimeout: 1
                waitForHBTimeout: true
                 additionalBlock: nil];
}

- (void)test_if_tsi_nt_is_on_and_storage_has_init_token_should_return_init_token {
    self.nativeGeneratorMock.expectedToken = @"token";
    UADSHeaderBiddingToken *initToken = [UADSHeaderBiddingToken newInitializeToken: @"init_token"];
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> sut = [self sut];

    [sut setInitToken: initToken.value];
    [self runTestUsingCreatedSut: sut
              withExpectedTokens: @[initToken]
        expectedGenerationCalled: 0
                       hbTimeout: 0
                waitForHBTimeout: false
                 additionalBlock: nil];
}

- (void)test_if_tsi_nt_is_on_and_storage_has_token_in_queue_should_return_token_from_queue {
    self.nativeGeneratorMock.expectedToken =  @"token";
    UADSHeaderBiddingToken *expectedToken = [UADSHeaderBiddingToken newWebToken: @"expectedToken"];
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> sut = [self sut];

    [sut createTokens: @[expectedToken.value]];
    [self runTestUsingCreatedSut: sut
              withExpectedTokens: @[expectedToken]
        expectedGenerationCalled: 0
                       hbTimeout: 0
                waitForHBTimeout: false
                 additionalBlock: nil];
}

- (void)test_if_a_queue_was_created_once_should_not_use_native_generator {
    UADSHeaderBiddingToken *expectedToken = [UADSHeaderBiddingToken newWebToken: @"token"];
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> sut = [self sut];

    [sut createTokens: @[expectedToken.value]];
    NSArray *array = @[
        expectedToken,
        [UADSHeaderBiddingToken newInvalidToken]
    ];

    [self runTestUsingCreatedSut: sut
              withExpectedTokens: array
        expectedGenerationCalled: 0
                       hbTimeout: 5
                waitForHBTimeout: true
                 additionalBlock: nil];
}

- (void)runTestWithExpectedTokens: (NSArray<UADSHeaderBiddingToken *> *)expectedTokens
           expectedGenerationCalled: (NSInteger)generateCalled
                          hbTimeout: (NSInteger)timeout
                    additionalBlock: (SUTAdditionalBlock)block {
    id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> sut = [self sutWithTimeoutValue: timeout];

    [self runTestUsingCreatedSut: sut
              withExpectedTokens: expectedTokens
        expectedGenerationCalled: generateCalled
                       hbTimeout: timeout
                waitForHBTimeout: true
                 additionalBlock: block];
}

- (void)runTestUsingCreatedSut: (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)sut
            withExpectedTokens: (NSArray<UADSHeaderBiddingToken *> *)expectedTokens
      expectedGenerationCalled: (NSInteger)generateCalled
                     hbTimeout: (NSInteger)timeout
              waitForHBTimeout: (BOOL)waitForHBTimeout
               additionalBlock: (SUTAdditionalBlock)block {
    XCTestExpectation *expectation = self.defaultExpectation;


    _configReaderMock.expectedConfiguration.hbTokenTimeout = timeout * 1000;
    expectation.expectedFulfillmentCount = expectedTokens.count;

    for (UADSHeaderBiddingToken *expectedToken in expectedTokens) {
        [sut getToken:^(UADSHeaderBiddingToken *_Nullable token) {
            XCTAssertEqualObjects(token.value, expectedToken.value);
            XCTAssertEqual(token.type, expectedToken.type);
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
