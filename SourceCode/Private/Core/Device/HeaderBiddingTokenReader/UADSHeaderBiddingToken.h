#import <Foundation/Foundation.h>
#import "UADSTokenType.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSHeaderBiddingToken : NSObject
@property (nonatomic, copy) NSString *value;
@property (nonatomic, assign) UADSTokenType type;

+ (instancetype)newNative: (NSString *)value;
+ (instancetype)newInitializeToken: (NSString *)value;
+ (instancetype)newWebToken: (NSString *)value;
+ (instancetype)newInvalidToken;
+ (instancetype)newInvalidNativeToken;
- (BOOL)        isValid;
@end

NS_ASSUME_NONNULL_END
