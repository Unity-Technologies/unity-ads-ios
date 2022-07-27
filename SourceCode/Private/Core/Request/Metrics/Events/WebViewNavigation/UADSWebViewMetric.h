#import "UADSMetric.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSWebViewMetric : UADSMetric
+ (instancetype)newWebViewTerminated;
+ (instancetype)newReloaded;
@end

NS_ASSUME_NONNULL_END
