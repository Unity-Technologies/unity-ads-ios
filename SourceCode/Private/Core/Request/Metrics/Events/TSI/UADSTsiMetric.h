#import "UADSMetric.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSTsiMetric : UADSMetric

+ (instancetype)newMissingToken;
+ (instancetype)newMissingStateId;
+ (instancetype)newMissingGameSessionId;
+ (instancetype)newInitStarted;
+ (instancetype)newInitTimeSuccess: (nullable NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newInitTimeFailure: (nullable NSNumber *)value tags: (nullable NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newTokenAvailabilityLatencyConfig: (nullable NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newTokenAvailabilityLatencyWebview: (NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newTokenResolutionRequestLatency: (nullable NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newTokenResolutionRequestFailureLatency: (NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newDeviceInfoCollectionLatency: (NSNumber *)value;
+ (instancetype)newDeviceInfoCompressionLatency: (NSNumber *)value;
+ (instancetype)newNativeGeneratedTokenAvailableWithTags: (nullable NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newNativeGeneratedTokenNullWithTags: (nullable NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newAsyncTokenNullWithTags: (nullable NSDictionary<NSString *, NSString *> *)tags;
+ (instancetype)newAsyncTokenTokenAvailableWithTags: (nullable NSDictionary<NSString *, NSString *> *)tags;


@end

NS_ASSUME_NONNULL_END
