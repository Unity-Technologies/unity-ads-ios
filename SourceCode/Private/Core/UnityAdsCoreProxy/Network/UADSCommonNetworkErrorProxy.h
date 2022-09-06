#import "UADSProxyReflection.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSCommonNetworkErrorProxy : UADSProxyReflection
- (NSString *)requestID;
- (NSString *)message;
- (NSString *)requestURL;
@end

NS_ASSUME_NONNULL_END
