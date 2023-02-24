#import "UADSMetric.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSSCARHeaderBiddingMetric : UADSMetric

+ (instancetype)newScarFetchStarted;
+ (instancetype)newScarFetchTimeSuccess: (nullable NSNumber *)value;
+ (instancetype)newScarFetchTimeFailure: (nullable NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags;

+ (instancetype)newScarSendStarted;
+ (instancetype)newScarSendTimeSuccess: (nullable NSNumber *)value;
+ (instancetype)newScarSendTimeFailure: (nullable NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags;

@end

NS_ASSUME_NONNULL_END
