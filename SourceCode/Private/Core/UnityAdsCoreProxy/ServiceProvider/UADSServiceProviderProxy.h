#import "UADSProxyReflection.h"
#import "UADSCommonNetworkProxy.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSServiceProviderProxy : UADSProxyReflection
+ (UADSServiceProviderProxy *)shared;
- (UADSCommonNetworkProxy *)  mainNetworkLayer;
- (void)                      saveConfiguration: (NSDictionary *)configDictionary;
@end

NS_ASSUME_NONNULL_END
