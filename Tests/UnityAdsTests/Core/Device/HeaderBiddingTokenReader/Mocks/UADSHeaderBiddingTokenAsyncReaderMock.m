#import "UADSHeaderBiddingTokenAsyncReaderMock.h"

@interface UADSHeaderBiddingTokenAsyncReaderMock ()

@property (nonatomic) UADSHeaderBiddingTokenCompletion completion;

@end

@implementation UADSHeaderBiddingTokenAsyncReaderMock

-(instancetype)init {
    SUPER_INIT;
    _tokenType = kUADSTokenNative;
    return self;
}

- (void)getToken: (UADSHeaderBiddingTokenCompletion)completion {
    _getTokenCount += 1;
    if (_original && _tokenType == kUADSTokenNative) {
        [_original getToken: completion];
        return;
    }
    if (!_shoudSkipCompletion) {
        completion([self generateToken]);
    } else {
        _completion = completion;
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

-(void)triggerGetTokenCompletion {
    GUARD(_completion);
    _completion([self generateToken]);
}

-(UADSHeaderBiddingToken*)generateToken {
    UADSHeaderBiddingToken* token = _tokenType == kUADSTokenNative ? [UADSHeaderBiddingToken newNative: _expectedToken] : [UADSHeaderBiddingToken newWebToken: _expectedToken];
    token.info = self.info;
    return token;
}

@end
