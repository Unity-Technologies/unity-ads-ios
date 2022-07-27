#import "UADSHeaderBiddingTokenAsyncReaderMock.h"

@implementation UADSHeaderBiddingTokenAsyncReaderMock

- (void)getToken: (UADSHeaderBiddingTokenCompletion)completion {
    _getTokenCount += 1;

    if (!_shoudSkipCompletion) {
        completion([UADSHeaderBiddingToken newNative: _expectedToken]);
    }
}

- (void)appendTokens: (nonnull NSArray<NSString *> *)tokens {
    _appendTokenCount += 1;
}

- (void)createTokens: (nonnull NSArray<NSString *> *)tokens {
    _createTokenCount += 1;
}

- (void)deleteTokens {
    _deleteTokenCount += 1;
}

- (nonnull NSString *)getToken {
    _getTokenSyncCount += 1;
    return _expectedToken;
}

- (void)setInitToken: (nullable NSString *)token {
    _setInitTokenCount += 1;
    _expectedToken = token;
}

- (void)setPeekMode: (BOOL)mode {
    _setPeekModeCount += 1;
}

@end
