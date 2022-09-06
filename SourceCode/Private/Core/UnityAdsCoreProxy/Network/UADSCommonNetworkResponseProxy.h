#import "UADSProxyReflection.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSCommonNetworkResponseProxy : UADSProxyReflection
- (NSString *)    id;
- (NSString *)    body;
- (NSDictionary *)headers;
- (NSNumber *)    status;
- (NSString *)    urlString;
@end

NS_ASSUME_NONNULL_END
