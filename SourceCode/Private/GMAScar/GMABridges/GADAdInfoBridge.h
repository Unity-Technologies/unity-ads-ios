#import "UADSProxyReflection.h"
#import "GADQueryInfoBridge.h"

NS_ASSUME_NONNULL_BEGIN

@class GADQueryInfoBridge;

@interface GADAdInfoBridge : UADSProxyReflection

+ (nullable instancetype)newWithQueryInfo: (GADQueryInfoBridge *)queryInfo
                                 adString: (NSString *)string;

@end

NS_ASSUME_NONNULL_END
