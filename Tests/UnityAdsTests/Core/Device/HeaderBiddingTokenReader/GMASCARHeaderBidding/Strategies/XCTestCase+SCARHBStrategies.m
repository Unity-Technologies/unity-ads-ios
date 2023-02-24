#import "XCTestCase+SCARHBStrategies.h"
#import "UADSSCARSignalSenderMock.h"
#import "XCTestCase+Convenience.h"

@implementation XCTestCase (SCARHBStrategies)

- (void) checkSenderCallHistoryCountIsOne:(UADSSCARSignalSenderMock*)sender withUUID:(NSString*)uuidString {
    XCTAssertTrue(sender.callHistory.count == 1, @"Signals should have been sent after signals returned to strategy");
    XCTAssertEqualObjects(sender.callHistory[0].uuidString, uuidString, @"uuid should be the same as the one that was passed in since no token has been returned yet");
}

- (void) hasValueSamePrefix:(NSString*)tokenValue withUUID:(NSString*)uuidString {
    NSString* prefix = [NSString stringWithFormat:@"%@:", uuidString];
    XCTAssertTrue([tokenValue hasPrefix:prefix], @"token value should have uuid prefix");
}


- (void) checkWithStrategy:(UADSHeaderBiddingTokenReaderWithSCARSignalsBaseStrategy*)strategy signalSenderMock:(UADSSCARSignalSenderMock*)signalSenderMock original:(UADSHeaderBiddingTokenAsyncReaderMock*)original stepAfterGetTokenTriggered:(void (^)(void))stepAfterGetToken getTokenReturn:(void(^)(UADSHeaderBiddingToken *))getTokenReturn {
    XCTestExpectation *exp = self.defaultExpectation;
    if (signalSenderMock) {
        exp.expectedFulfillmentCount = 2;
        signalSenderMock.callExpectation = exp;
    }
    [strategy getToken:^(UADSHeaderBiddingToken *_Nullable token) {
        getTokenReturn(token);
        [exp fulfill];
    }];
    stepAfterGetToken();
    [original triggerGetTokenCompletion];
    [self waitForExpectations: @[exp]
                      timeout: 1];
}

- (void) checkWithStrategy:(UADSHeaderBiddingTokenReaderWithSCARSignalsBaseStrategy*)strategy original:(UADSHeaderBiddingTokenAsyncReaderMock*)original stepAfterGetTokenTriggered:(void (^)(void))stepAfterGetToken getTokenReturn:(void(^)(UADSHeaderBiddingToken *))getTokenReturn {
    [self checkWithStrategy:strategy signalSenderMock:nil original:original stepAfterGetTokenTriggered:stepAfterGetToken getTokenReturn:getTokenReturn];
}

@end
