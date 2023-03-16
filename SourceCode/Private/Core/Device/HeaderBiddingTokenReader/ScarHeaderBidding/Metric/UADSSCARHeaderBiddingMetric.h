#import "UADSMetric.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSSCARHeaderBiddingMetric : UADSMetric

+ (instancetype)newScarFetchStartedWithIsAsync:(BOOL)isAsync;
+ (instancetype)newScarFetchTimeSuccess: (nullable NSNumber *)value isAsync:(BOOL)isAsync;
+ (instancetype)newScarFetchTimeFailure: (nullable NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags isAsync:(BOOL)isAsync;

+ (instancetype)newScarSendStartedWithIsAsync:(BOOL)isAsync;
+ (instancetype)newScarSendTimeSuccess: (nullable NSNumber *)value isAsync:(BOOL)isAsync;
+ (instancetype)newScarSendTimeFailure: (nullable NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags isAsync:(BOOL)isAsync;

@end

NS_ASSUME_NONNULL_END
