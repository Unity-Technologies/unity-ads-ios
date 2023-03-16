#import "UADSHeaderBiddingTokenReaderWithSCARSignalsLazyStrategy.h"
#import "UADSHeaderBiddingTokenReaderWithSCARSignalsBaseStrategy+Internal.h"

@implementation UADSHeaderBiddingTokenReaderWithSCARSignalsLazyStrategy


- (void)getToken:(UADSHeaderBiddingTokenCompletion)completion {
    __block NSString* uuidString;
    
    id signalCompletion = ^(UADSSCARSignals *_Nullable signals) {
        [self.scarSignalSender sendSCARSignalsWithUUIDString:uuidString signals:signals isAsync:true];
    };
    
    UADSHeaderBiddingTokenCompletion injectedCompletion = ^(UADSHeaderBiddingToken *_Nullable token) {
        if (token.isValid) {
            uuidString = token.uuidString;
            [self.scarSignalReader requestSCARSignalsWithIsAsync:true completion:signalCompletion];
            token = [self setUUIDString:uuidString ifRemoteToken:token];
        }
        completion(token);
    };
    
    [super getToken:injectedCompletion];
}

@end
