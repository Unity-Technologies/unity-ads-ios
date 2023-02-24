#import <XCTest/XCTest.h>
#import "UADSHeaderBiddingTokenReaderWithSCARSignalsLazyStrategy.h"
#import "UADSHeaderBiddingTokenAsyncReaderMock.h"
#import "UADSSCARHeaderBiddingStrategyFactoryMock.h"
#import "WebRequestFactoryMock.h"
#import "UADSSCARSignalReaderMock.h"
#import "UADSSCARSignalSenderMock.h"
#import "USRVBodyCompressorMock.h"
#import "UADSConfigurationReaderMock.h"
#import "UADSHeaderBiddingTokenReaderWithSCARSignalsBaseStrategy+Internal.h"
#import "XCTestCase+Convenience.h"
#import "UADSUniqueIdGeneratorMock.h"
#import "UADSJSONCompressorMock.h"
#import "XCTestCase+SCARHBStrategies.h"

@interface UADSHeaderBiddingTokenReaderWithSCARSignalsLazyStrategyTests : XCTestCase
@property (nonatomic, strong) UADSHeaderBiddingTokenReaderWithSCARSignalsLazyStrategy *strategyToTest;
@property (nonatomic, strong) UADSHeaderBiddingTokenReaderSCARSignalsConfig* configMock;
@property (nonatomic, strong) UADSHeaderBiddingTokenAsyncReaderMock* originalMock;
@property (nonatomic, strong) UADSSCARSignalReaderMock* signalReaderMock;
@property (nonatomic, strong) UADSSCARSignalSenderMock* signalSenderMock;

@end

@implementation UADSHeaderBiddingTokenReaderWithSCARSignalsLazyStrategyTests

- (void)setUp {
    _originalMock = [UADSHeaderBiddingTokenAsyncReaderMock new];
    _signalReaderMock = [UADSSCARSignalReaderMock new];
    _signalSenderMock = [UADSSCARSignalSenderMock new];
    _configMock = [UADSHeaderBiddingTokenReaderSCARSignalsConfig new];
    
    _strategyToTest = [UADSHeaderBiddingTokenReaderWithSCARSignalsLazyStrategy decorateOriginal:_originalMock config:_configMock];
    _strategyToTest.scarSignalReader = _signalReaderMock;
    _strategyToTest.scarSignalSender = _signalSenderMock;
    _originalMock.expectedToken = @"tokenValue";
    _originalMock.shoudSkipCompletion = true;
}

- (void)test_signals_recieved_and_signals_sent_before_token_returned {
    [self checkWithStrategy:_strategyToTest original:_originalMock stepAfterGetTokenTriggered:^ {
        [self.signalReaderMock triggerSignalCompletion];
        XCTAssertEqual(self.signalSenderMock.callHistory.count,0, @"Signals should not have been sent until both token and signals received");
    } getTokenReturn:^ (UADSHeaderBiddingToken *_Nullable token) {
        XCTAssertEqual(self.signalSenderMock.callHistory.count,0, @"Signals should not have been sent until both token and signals received");
        [self.signalReaderMock triggerSignalCompletion];
        [self checkSenderCallHistoryCountIsOne:self.signalSenderMock withUUID:token.uuidString];
    }];
    
}


- (void)test_signals_received_and_signals_sent_after_token_recieved {
    [self checkWithStrategy:_strategyToTest original:_originalMock stepAfterGetTokenTriggered:^ { } getTokenReturn:^ (UADSHeaderBiddingToken *_Nullable token) {
        XCTAssertEqual(self.signalSenderMock.callHistory.count,0, @"Signals should not have been sent until both token and signals received");
        [self.signalReaderMock triggerSignalCompletion];
        [self checkSenderCallHistoryCountIsOne:self.signalSenderMock withUUID:token.uuidString];
    }];
}

- (void)test_signals_sent_as_soon_as_received_remote_token_and_signals {
    _originalMock.tokenType = kUADSTokenRemote;
    [self checkWithStrategy:_strategyToTest original:_originalMock stepAfterGetTokenTriggered:^ { } getTokenReturn:^ (UADSHeaderBiddingToken *_Nullable token) {
        XCTAssertEqual(self.signalSenderMock.callHistory.count,0, @"Signals should not have been sent until both token and signals received");
        [self.signalReaderMock triggerSignalCompletion];
        [self hasValueSamePrefix:token.value withUUID:token.uuidString];
        [self checkSenderCallHistoryCountIsOne:self.signalSenderMock withUUID:token.uuidString];
    }];
}

- (void)test_nil_signals_sent_as_soon_as_signal_and_token_received {
    _signalReaderMock.signals = nil;
    [self checkWithStrategy:_strategyToTest original:_originalMock stepAfterGetTokenTriggered:^ { } getTokenReturn:^ (UADSHeaderBiddingToken *_Nullable token) {
        XCTAssertEqual(self.signalSenderMock.callHistory.count,0, @"Signals should not have been sent until both token and signals received");
        [self.signalReaderMock triggerSignalCompletion];
        [self checkSenderCallHistoryCountIsOne:self.signalSenderMock withUUID:token.uuidString];
    }];
}

- (void)test_signals_not_sent_as_received_nil_token {
    _originalMock.expectedToken = nil;
    [self checkWithStrategy:_strategyToTest original:_originalMock stepAfterGetTokenTriggered:^ {
        XCTAssertEqual(self.signalSenderMock.callHistory.count,0, @"Signals should not have been sent until both token and signals received");
    } getTokenReturn:^ (UADSHeaderBiddingToken *_Nullable token) {
        [self.signalReaderMock triggerSignalCompletion];
        XCTAssertEqual(self.signalSenderMock.callHistory.count,0, @"Token is invalid, no point sending signals");
    }];
}

- (void)test_x_signals_recieved_and_signals_sent_before_x_token_returned_multithread {
    int iterations = 500;
    self.signalReaderMock.shouldAutoComplete = true;
    self.originalMock.shoudSkipCompletion = false;
    [self asyncExecuteTimes:iterations block:^(XCTestExpectation *_Nonnull expectation, int index) {
        [self.strategyToTest getToken:^(UADSHeaderBiddingToken *_Nullable token) {
            [expectation fulfill];
        }];
    }];
    XCTAssertEqual(self.signalSenderMock.callHistory.count,iterations, @"Signals should have the same count as the iterations");
}

- (void)test_x_signals_sent_same_thread {
    NSMutableArray<UADSHeaderBiddingToken*>* tokens = [NSMutableArray new];
    NSMutableArray<NSString*>* tokenValues = [NSMutableArray new];
    int iterations = 50;
    XCTestExpectation *exp = self.defaultExpectation;
    exp.expectedFulfillmentCount = iterations;
    for (int i=0; i<iterations; i++) {
        NSString* tokenValue = [NSString stringWithFormat:@"token%d", i];
        [tokenValues addObject:tokenValue];
        _originalMock.expectedToken = tokenValue;
        [_strategyToTest getToken:^(UADSHeaderBiddingToken *_Nullable token) {
            [self.signalReaderMock triggerSignalCompletion];
            [tokens addObject:token];
            [exp fulfill];
        }];
        [_originalMock triggerGetTokenCompletion];
    }
    [self waitForExpectations: @[exp]
                      timeout: 1];
    [self waitForTimeInterval: 0.1];
    
    for (int i=0;i<iterations;i++) {
        UADSHeaderBiddingToken* token = [tokens objectAtIndex:i];
        NSString* tokenValue = [tokenValues objectAtIndex:i];
        XCTAssertEqualObjects(token.value, tokenValue, @"token value should be the same as the value set for the loop");
        
        XCTAssertEqualObjects(self.signalSenderMock.callHistory[i].uuidString, token.uuidString, @"uuid should be the same as the one that was passed to the signals sender");
    }
    XCTAssertEqual(self.signalSenderMock.callHistory.count,iterations, @"X number of signals should have been sent");
    
}

@end
