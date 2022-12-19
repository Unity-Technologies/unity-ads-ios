#import "UADSProxyReflection.h"

NS_ASSUME_NONNULL_BEGIN

@interface GADExtrasBridge : UADSProxyReflection
@property (nonatomic, copy, nullable) NSDictionary *additionalParameters;

+ (instancetype)getNewExtras;
@end

NS_ASSUME_NONNULL_END
