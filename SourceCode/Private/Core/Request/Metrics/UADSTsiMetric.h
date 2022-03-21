#import "UADSMetric.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSTsiMetric : UADSMetric

+ (instancetype)newMissingTokenWithTags: (nullable NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newMissingStateIdWithTags: (nullable NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newMissingGameSessionIdWithTags: (nullable NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newInitStartedWithTags: (nullable NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newInitTimeSuccess: (nullable NSNumber *)value withTags: (nullable NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newInitTimeFailure: (nullable NSNumber *)value withTags: (nullable NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newTokenAvailabilityLatencyConfig: (nullable NSNumber *)value withTags: (nullable NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newTokenAvailabilityLatencyWebview: (NSNumber *)value withTags: (NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newTokenResolutionRequestLatency: (nullable NSNumber *)value withTags: (nullable NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newEmergencySwitchOffWithTags: (NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newDeviceInfoCollectionLatency: (NSNumber *)value withTags: (nullable NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newDeviceInfoCompressionLatency: (NSNumber *)value withTags: (nullable NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newNativeGeneratedTokenAvailableWithTags: (nullable NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newNativeGeneratedTokenNullWithTags: (nullable NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newAsyncTokenNullWithTags: (nullable NSDictionary<NSString *, NSString *> *)tags;
@end

NS_ASSUME_NONNULL_END
