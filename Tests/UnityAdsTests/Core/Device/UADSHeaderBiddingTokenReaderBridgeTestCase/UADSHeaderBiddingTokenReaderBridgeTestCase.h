#import <XCTest/XCTest.h>
#import "UADSHeaderBiddingTokenReaderBridge.h"
#import "UADSConfigurationReaderMock.h"
#import "UADSHeaderBiddingTokenAsyncReaderMock.h"

#define DEFAULT_WAITING_INTERVAL 1
typedef void (^SUTAdditionalBlock)(id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>);

@interface UADSHeaderBiddingTokenReaderBridgeTestCase : XCTestCase
@property (nonatomic, strong) UADSConfigurationReaderMock *configReaderMock;
@property (nonatomic, strong) UADSHeaderBiddingTokenAsyncReaderMock *nativeGeneratorMock;
@property (nonatomic, strong) id<UADSHeaderBiddingTokenCRUD> tokenCRUDMock;
- (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)createBridge;
- (id<UADSHeaderBiddingTokenCRUD>)                                   tokenCRUD;

- (void)                                                          runTestWithNativeGeneration: (BOOL)nativeGeneration
                                                                           withExpectedTokens: (NSArray<UADSHeaderBiddingToken *> *)expectedTokens
                                                                     expectedGenerationCalled: (NSInteger)generateCalled
                                                                                    hbTimeout: (NSInteger)timeout
                                                                              additionalBlock: (SUTAdditionalBlock)block;
- (void)runTestUsingCreatedSut: (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)sut
            withExpectedTokens: (NSArray<UADSHeaderBiddingToken *> *)expectedTokens
      expectedGenerationCalled: (NSInteger)generateCalled
                     hbTimeout: (NSInteger)timeout
              waitForHBTimeout: (BOOL)waitForHBTimeout
               additionalBlock: (SUTAdditionalBlock)block;

@end
