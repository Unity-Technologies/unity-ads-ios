#import "UADSProxyReflection.h"
#import "SKAdImpressionProxy.h"
NS_ASSUME_NONNULL_BEGIN

@interface SKAdNetworkProxy : UADSProxyReflection
+ (void)startImpression: (SKAdImpressionProxy *)impression
      completionHandler: (UADSNSErrorCompletion)completion;

+ (void)endImpression: (SKAdImpressionProxy *)impression
    completionHandler: (UADSNSErrorCompletion)completion;
@end

NS_ASSUME_NONNULL_END
