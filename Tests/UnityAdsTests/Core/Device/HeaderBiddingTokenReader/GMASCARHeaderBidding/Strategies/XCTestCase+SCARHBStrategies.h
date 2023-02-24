#import <XCTest/XCTest.h>
#import "UADSSCARSignalSenderMock.h"
#import "UADSHeaderBiddingToken.h"
#import "UADSHeaderBiddingTokenReaderWithSCARSignalsBaseStrategy.h"
#import "UADSHeaderBiddingTokenAsyncReaderMock.h"
#import "UADSSCARSignalSenderMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface XCTestCase (SCARHBStrategies)

- (void) checkSenderCallHistoryCountIsOne:(UADSSCARSignalSenderMock*)sender withUUID:(NSString*)uuidString;
- (void) hasValueSamePrefix:(NSString*)tokenValue withUUID:(NSString*)uuidString;
- (void) checkWithStrategy:(UADSHeaderBiddingTokenReaderWithSCARSignalsBaseStrategy*)strategy original:(UADSHeaderBiddingTokenAsyncReaderMock*)original stepAfterGetTokenTriggered:(void (^)(void))stepAfterGetToken getTokenReturn:(void(^)(UADSHeaderBiddingToken *))getTokenReturn;
- (void) checkWithStrategy:(UADSHeaderBiddingTokenReaderWithSCARSignalsBaseStrategy*)strategy signalSenderMock:(UADSSCARSignalSenderMock*)signalSenderMock original:(UADSHeaderBiddingTokenAsyncReaderMock*)original stepAfterGetTokenTriggered:(void (^)(void))stepAfterGetToken getTokenReturn:(void(^)(UADSHeaderBiddingToken *))getTokenReturn;

@end

NS_ASSUME_NONNULL_END
