#import <Foundation/Foundation.h>
#import "UADSMetric.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSPrivacyMetrics : UADSMetric
+ (instancetype)newPrivacyRequestSuccessLatency: (nullable NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newPrivacyRequestErrorLatency: (nullable NSDictionary<NSString *, NSString *> *)tags;
@end

NS_ASSUME_NONNULL_END
