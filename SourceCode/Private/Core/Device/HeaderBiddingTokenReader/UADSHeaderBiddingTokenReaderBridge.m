#import "UADSHeaderBiddingTokenReaderBridge.h"
#import "UADSClosureWithTimeout.h"
#import "NSArray+Convenience.h"

@interface UADSHeaderBiddingTokenReaderBridge ()
@property (nonatomic, strong) id<UADSHeaderBiddingAsyncTokenReader> nativeTokenGenerator;
@property (nonatomic, strong) id<UADSHeaderBiddingTokenCRUD> tokenCRUD;
@property (nonatomic, strong) id<UADSConfigurationReader>configurationReader;
@property (nonatomic, strong) NSArray<UADSClosureWithTimeout *> *observers;
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
    base.observers = @[];
    base.tokenQueueIsCreated = false;
    return base;
}

- (void)getToken: (nonnull UADSHeaderBiddingTokenCompletion)completion {
    if (self.shouldGenerateToken) {
        [self generateNativeToken: completion];
        return;
    }

    NSString *tokenFromStorage = [self getToken];

    if ([self isValidToken: tokenFromStorage]) {
        completion(tokenFromStorage, kUADSTokenRemote);
        return;
    }

    [self saveAsObserver: completion
                    type: kUADSTokenRemote];
}

- (BOOL)isValidToken: (NSString *)token {
    return token != nil && ![token isEqualToString: @""];
}

- (BOOL)shouldGenerateToken {
    return self.currentExperiments.isHeaderBiddingTokenGenerationEnabled && !self.tokenQueueIsCreated;
}

- (UADSConfigurationExperiments *)currentExperiments {
    return _configurationReader.getCurrentConfiguration.experiments ? : [UADSConfigurationExperiments newWithJSON: @{}];
}

- (void)generateNativeToken: (nonnull UADSHeaderBiddingTokenCompletion)completion {
    NSUUID *observerId = [self saveAsObserver: completion
                                         type: kUADSTokenNative];

    __weak typeof(self) weakSelf = self;
    [_nativeTokenGenerator getToken:^(NSString *_Nullable token, UADSTokenType type) {
        [weakSelf notifyAndRemoveObserverWithID: observerId
                                          token: token];
    }];
}

- (NSUUID *)saveAsObserver: (nonnull UADSHeaderBiddingTokenCompletion)completion type: (UADSTokenType)type {
    NSInteger timeout = _configurationReader.getCurrentConfiguration.hbTokenTimeout / 1000;

    __weak typeof(self) weakSelf = self;
    id timeoutHandler = ^(NSUUID *id) {
        [weakSelf notifyAndRemoveObserverWithID: id
                                          token: nil];
    };
    UADSClosureWithTimeout *observer = [UADSClosureWithTimeout newWithType: type
                                                          timeoutInSeconds: timeout
                                                         andTimeoutClosure: timeoutHandler
                                                                  andBlock: completion];

    @synchronized (self) {
        _observers = [_observers arrayByAddingObject: observer];
    }
    return observer.id;
}

- (void)notifyAndRemoveObserverWithID: (NSUUID *)id token: (NSString *)token {
    @synchronized (self) {
        _observers = [_observers uads_removingFirstWhere:^bool (UADSClosureWithTimeout *_Nonnull observer) {
            if ([observer.id.UUIDString isEqualToString: id.UUIDString]) {
                [observer callClosureWith: token];
                return true;
            } else {
                return false;
            }
        }];
    }
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
        _observers = [_observers uads_removingFirstWhere:^bool (UADSClosureWithTimeout *_Nonnull observer) {
            return [self notifyObserverWithValidToken: observer];
        }];
    }
}

- (BOOL)notifyObserverWithValidToken: (UADSClosureWithTimeout *)observer {
    NSString *token = [_tokenCRUD getToken];

    if ([self isValidToken: token]) {
        [observer callClosureWith: token];
        return true;
    } else {
        return false;
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
