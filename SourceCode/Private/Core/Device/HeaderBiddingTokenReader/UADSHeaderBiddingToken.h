#import <Foundation/Foundation.h>
#import "UADSTokenType.h"
#import "USRVBodyBase64GzipCompressor.h"
#import "UADSUniqueIdGenerator.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSHeaderBiddingToken : NSObject
@property (nonatomic, copy) NSString *value;
@property (nonatomic, assign) UADSTokenType type;
@property (nonatomic) NSString *uuidString;
@property (nonatomic) NSMutableDictionary *info;
@property (nonnull, copy) NSString *customPrefix;

+ (instancetype)newNative: (NSString *)value;
+ (instancetype)newInitializeToken: (NSString *)value;
+ (instancetype)newWebToken: (NSString *)value;
+ (instancetype)newInvalidToken;
+ (instancetype)newInvalidNativeToken;
- (BOOL)        isValid;


- (instancetype)newWithValue: (NSString *)value;

@end

NS_ASSUME_NONNULL_END
