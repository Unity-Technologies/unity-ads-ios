#import "UADSHeaderBiddingTokenReaderWithSCARSignalsEagerStrategy.h"
#import "UADSHeaderBiddingTokenReaderWithSCARSignalsBaseStrategy+Internal.h"
#import "UADSUUIDStringGenerator.h"

@implementation UADSHeaderBiddingTokenReaderWithSCARSignalsEagerStrategy

-(instancetype)init {
    SUPER_INIT;
    _uniqueIdGenerator = [UADSUUIDStringGenerator new];
    return self;
}

- (void)getToken:(UADSHeaderBiddingTokenCompletion)completion {
    __block UADSSCARSignals *_Nullable blockSignals;
    __block NSString* uuidString = [self.uniqueIdGenerator generateId];
    __block const NSString* nonChangingValue = @"";
    
    id signalCompletion = ^(UADSSCARSignals *_Nullable signals) {
        @synchronized (nonChangingValue) {
            blockSignals = signals;
        }
        [self.scarSignalSender sendSCARSignalsWithUUIDString:uuidString signals:blockSignals];
    };
    
    [self.scarSignalReader requestSCARSignalsWithCompletion:signalCompletion];
    
    UADSHeaderBiddingTokenCompletion injectedCompletion = ^(UADSHeaderBiddingToken *_Nullable token) {
        if (token.isValid) {
            @synchronized (nonChangingValue) {
                if (blockSignals) {//The signals have been sent
                    token = [self regenerateTokenValueWithUUIDString:uuidString token:token];
                } else {//The signals have not been sent yet, override uuid with token uuid instead
                    uuidString = token.uuidString;
                }
            }
            token = [self setUUIDString:uuidString ifRemoteToken:token];
        }
        completion(token);
    };
    
    [super getToken:injectedCompletion];
}

- (UADSHeaderBiddingToken *) regenerateTokenValueWithUUIDString:(NSString*) uuidString token:(UADSHeaderBiddingToken *) token {
    if (token.type == kUADSTokenRemote) {
        return token;
    }
    UADSHeaderBiddingToken *newToken = token;
    newToken.uuidString = uuidString;
    NSString *tokenValue = [self.config.compressor compressedIntoString: newToken.info];
    newToken = [newToken newWithValue: tokenValue ? [NSString stringWithFormat:@"%@%@", newToken.customPrefix ?: @"", tokenValue ?: @""] : token.value];
    return newToken;
}

@end
