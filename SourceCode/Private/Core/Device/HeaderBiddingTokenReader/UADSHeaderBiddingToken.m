#import "UADSHeaderBiddingToken.h"
#import "NSMutableDictionary+SafeOperations.h"
#import "UADSUUIDStringGenerator.h"

@implementation UADSHeaderBiddingToken

@synthesize uuidString = _uuidString;

+ (instancetype)newNative: (NSString *)value {
    UADSHeaderBiddingToken *token = [self new];

    token.value = value;
    token.type = kUADSTokenNative;
    return token;
}

+ (instancetype)newWebToken: (NSString *)value {
    UADSHeaderBiddingToken *token = [self new];
    token.uuidString = [NSUUID new].UUIDString;

    token.value = value;
    token.type = kUADSTokenRemote;
    return token;
}

+ (instancetype)newInitializeToken: (NSString *)value {
    UADSHeaderBiddingToken *token = [self new];
    token.uuidString = [NSUUID new].UUIDString;

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

# pragma SCAR-HB-Specific

- (NSString*) uuidString {
    return _uuidString;
}

- (void) setUuidString:(NSString *)uuid {
    _uuidString = uuid;
    [_info uads_setValueIfNotNil:uuid forKey:@"tid"];
}

- (void)setInfo:(NSMutableDictionary *)info {
    [info uads_setValueIfNotNil:_uuidString forKey:@"tid"];
    _info = info;
}

- (instancetype)newWithValue: (NSString *)value {
    UADSHeaderBiddingToken *newToken = [[self class] new];

    newToken.value = value;
    newToken.type = self.type;
    newToken.customPrefix = [self.customPrefix copy];
    newToken.uuidString = [self.uuidString copy];
    newToken.info = [NSMutableDictionary dictionaryWithDictionary:self.info];
    return newToken;
}

@end

