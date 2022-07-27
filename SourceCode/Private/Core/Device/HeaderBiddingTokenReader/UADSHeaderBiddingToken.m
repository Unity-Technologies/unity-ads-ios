#import "UADSHeaderBiddingToken.h"

@implementation UADSHeaderBiddingToken
+ (instancetype)newNative: (NSString *)value {
    UADSHeaderBiddingToken *token = [self new];

    token.value = value;
    token.type = kUADSTokenNative;
    return token;
}

+ (instancetype)newWebToken: (NSString *)value {
    UADSHeaderBiddingToken *token = [self new];

    token.value = value;
    token.type = kUADSTokenRemote;
    return token;
}

+ (instancetype)newInitializeToken: (NSString *)value {
    UADSHeaderBiddingToken *token = [self new];

    token.value = value;
    token.type = kUADSTokenRemote;
    return token;
}

+ (instancetype)newInvalidToken {
    UADSHeaderBiddingToken *token = [self new];

    token.type = kUADSTokenRemote;
    return token;
}

+ (instancetype)newInvalidNativeToken {
    UADSHeaderBiddingToken *token = [self new];

    token.type = kUADSTokenNative;
    return token;
}

- (BOOL)isValid {
    return _value != nil && ![_value isEqual: @""];
}

@end
