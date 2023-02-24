#import "UADSHeaderBiddingTokenReaderWithSCARSignalsBaseStrategy.h"
#import "UADSHeaderBiddingTokenReaderWithSCARSignalsBaseStrategy+Internal.h"
#import "UADSSCARWebRequestSignalSender.h"
#import "UADSSCARRawSignalsReader.h"

@implementation UADSHeaderBiddingTokenReaderWithSCARSignalsBaseStrategy

+ (instancetype)decorateOriginal: (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)original config:(UADSHeaderBiddingTokenReaderSCARSignalsConfig*)config {
    UADSSCARWebRequestSignalSender* scarSignalSender =  [UADSSCARWebRequestSignalSender new];
    scarSignalSender.config = config;
    
    UADSSCARRawSignalsReader* scarSignalReader =  [UADSSCARRawSignalsReader new];
    scarSignalReader.config = config;
    
    UADSHeaderBiddingTokenReaderWithSCARSignalsBaseStrategy *strategy = [self new];
    strategy.original = original;
    strategy.config = config;
    strategy.scarSignalSender = scarSignalSender;
    strategy.scarSignalReader = scarSignalReader;
    return strategy;
}

- (void)getToken:(nonnull UADSHeaderBiddingTokenCompletion)completion {
    [self.original getToken:completion];
}

- (void)appendTokens:(nonnull NSArray<NSString *> *)tokens {
    [self.original appendTokens:tokens];
}

- (void)createTokens:(nonnull NSArray<NSString *> *)tokens {
    [self.original createTokens:tokens];
}

- (void)deleteTokens {
    [self.original deleteTokens];
}

- (nonnull NSString *)getToken {
    NSString* tokenValue = [self.original getToken];
    NSString* uuidString = [NSUUID new].UUIDString;
    tokenValue = [self uuidPrefixedTokenValueWithUUIDString:uuidString forTokenValue:tokenValue];
    id signalCompletion = ^(UADSSCARSignals *_Nullable signals) {
        [self.scarSignalSender sendSCARSignalsWithUUIDString:uuidString signals:signals];
    };
    
    [self.scarSignalReader requestSCARSignalsWithCompletion:signalCompletion];
    
    return tokenValue;
}

- (void)setInitToken:(nullable NSString *)token {
    [self.original setInitToken:token];
}

- (void)setPeekMode:(BOOL)mode {
    [self.original setPeekMode:mode];
}

- (UADSHeaderBiddingToken*) setUUIDString:(NSString*)uuidString ifRemoteToken:(UADSHeaderBiddingToken*)token {
    UADSHeaderBiddingToken* newToken = token;
    if (newToken.type == kUADSTokenRemote && newToken.isValid) {
        newToken = [newToken newWithValue: [self uuidPrefixedTokenValueWithUUIDString:uuidString forTokenValue:newToken.value]];
    }
    return newToken;
}

- (NSString*) uuidPrefixedTokenValueWithUUIDString:(NSString*)uuidString forTokenValue:(NSString*)tokenValue {//Only use this for remote tokens, not native tokens
    return [NSString stringWithFormat:@"%@:%@", uuidString, tokenValue];
}


@end
