#import "UADSHeaderBiddingTokenReaderWithSCARSignals.h"
#import "UADSServiceProvider.h"
#import "UADSSCARHeaderBiddingFetchSendStrategyFactory.h"

@interface UADSHeaderBiddingTokenReaderWithSCARSignals ()
@property (nonatomic, strong) id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> original;
@property (nonatomic, strong) UADSHeaderBiddingTokenReaderSCARSignalsConfig* config;

@end

@implementation UADSHeaderBiddingTokenReaderWithSCARSignals

+ (instancetype)decorateOriginal: (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)original withConfig:(UADSHeaderBiddingTokenReaderSCARSignalsConfig*)config {
    UADSHeaderBiddingTokenReaderWithSCARSignals *decorator = [self new];
    decorator.original = original;
    decorator.config = config;
    return decorator;
}

-(id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)strategy {
    return [self.config.strategyFactory strategyWithOriginal:self.original];
}

- (void)getToken:(nonnull UADSHeaderBiddingTokenCompletion)completion {
    return [[self strategy] getToken:completion];
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
    return [[self strategy] getToken];
}

- (void)setInitToken:(nullable NSString *)token {
    [self.original setInitToken:token];
}

- (void)setPeekMode:(BOOL)mode {
    [self.original setPeekMode:mode];
}


@end
