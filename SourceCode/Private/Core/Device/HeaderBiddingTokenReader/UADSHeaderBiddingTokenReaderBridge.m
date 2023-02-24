#import "UADSHeaderBiddingTokenReaderBridge.h"
#import "NSArray+Convenience.h"

@interface UADSHeaderBiddingTokenReaderBridge ()
@property (nonatomic, strong) id<UADSHeaderBiddingAsyncTokenReader> nativeTokenGenerator;
@property (nonatomic, strong) id<UADSHeaderBiddingTokenCRUD> tokenCRUD;
@property (nonatomic, strong) id<UADSConfigurationReader>configurationReader;
@property (nonatomic, strong) UADSGenericMediator<UADSHeaderBiddingToken *> *mediator;
@property (nonatomic) BOOL tokenQueueIsCreated;
@end

@implementation UADSHeaderBiddingTokenReaderBridge

+ (instancetype)newWithNativeTokenGenerator: (id<UADSHeaderBiddingAsyncTokenReader>)nativeTokenGenerator
                               andTokenCRUD: (id<UADSHeaderBiddingTokenCRUD>)tokenCRUD
                     andConfigurationReader: (id<UADSConfigurationReader>)configurationReader {
    UADSHeaderBiddingTokenReaderBridge *base = [self new];

    base.nativeTokenGenerator = nativeTokenGenerator;
    base.tokenCRUD = tokenCRUD;
    base.configurationReader = configurationReader;
    base.tokenQueueIsCreated = false;
    base.mediator = [UADSGenericMediator new];
    base.mediator.timeoutInSeconds = configurationReader.getCurrentConfiguration.hbTokenTimeout / 1000;
    return base;
}

- (void)getToken: (nonnull UADSHeaderBiddingTokenCompletion)completion {
    UADSTokenType tokenType = self.shouldGenerateToken ? kUADSTokenNative : kUADSTokenRemote;

    [self saveAsObserver: completion
                    type: tokenType];
    [self notifyIfThereIsValidToken];
}

- (BOOL)shouldGenerateToken {
    return !self.tokenQueueIsCreated;
}

- (UADSConfigurationExperiments *)currentExperiments {
    return _configurationReader.currentSessionExperiments;
}

- (void)saveAsObserver: (nonnull UADSHeaderBiddingTokenCompletion)completion type: (UADSTokenType)type {
    [_mediator subscribe:^(UADSHeaderBiddingToken *_Nonnull token) {
        completion(token);
    }
              andTimeout:^{
         UADSHeaderBiddingToken *token = [UADSHeaderBiddingToken new];
         token.type = type;
         completion(token);
     }];
}

- (void)appendTokens: (nonnull NSArray<NSString *> *)tokens {
    [_tokenCRUD appendTokens: tokens];

    if ([tokens count] > 0) {
        [self notifyObserversAndCleanQueue];
    }
}

- (void)createTokens: (nonnull NSArray<NSString *> *)tokens {
    [_tokenCRUD createTokens: tokens];

    if ([tokens count] > 0) {
        [self notifyObserversAndCleanQueue];
    }
}

- (void)notifyObserversAndCleanQueue {
    @synchronized (self) {
        self.tokenQueueIsCreated = true;
        NSInteger count = _mediator.count;

        for (int i = 0; i < count; i++) {
            [self notifyIfThereIsValidToken];
        }
    }
}

- (void)notifyIfThereIsValidToken {
    if (self.shouldGenerateToken) {
        UADSGenericMediator *cMediator = self.mediator;
        [_nativeTokenGenerator getToken:^(UADSHeaderBiddingToken *_Nullable token) {
            [cMediator notifyObserversSeparatelyWithObjectsAndRemove: @[token]];
        }];
        return;
    }

    UADSHeaderBiddingToken *token = [UADSHeaderBiddingToken newWebToken: [self getToken]];

    if (token.isValid) {
        [_mediator notifyObserversSeparatelyWithObjectsAndRemove: @[token]];
    }
}

- (void)deleteTokens {
    [_tokenCRUD deleteTokens];
}

- (nonnull NSString *)getToken {
    return [_tokenCRUD getToken];
}

- (void)setInitToken: (nullable NSString *)token {
    [_tokenCRUD setInitToken: token];

    if (token) {
        [self notifyObserversAndCleanQueue];
    }
}

- (void)setPeekMode: (BOOL)mode {
    [_tokenCRUD setPeekMode: mode];
}

@end
