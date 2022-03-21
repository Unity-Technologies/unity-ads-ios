#import "UADSTsiMetric.h"

@implementation UADSTsiMetric

+ (instancetype)newMissingTokenWithTags: (NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_missing_token"
                       value: nil
                        tags: tags];
}

+ (instancetype)newMissingStateIdWithTags: (NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_missing_state_id"
                       value: nil
                        tags: tags];
}

+ (instancetype)newMissingGameSessionIdWithTags: (NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_missing_game_session_id"
                       value: nil
                        tags: tags];
}

+ (instancetype)newInitTimeSuccess: (NSNumber *)value withTags: (NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_initialization_time_success"
                       value: value
                        tags: tags];
}

+ (instancetype)newInitTimeFailure: (NSNumber *)value withTags: (NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_initialization_time_failure"
                       value: value
                        tags: tags];
}

+ (instancetype)newInitStartedWithTags: (NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_initialization_started"
                       value: nil
                        tags: tags];
}

+ (instancetype)newTokenAvailabilityLatencyConfig: (NSNumber *)value withTags: (NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_token_availability_latency_config"
                       value: value
                        tags: tags];
}

+ (instancetype)newTokenAvailabilityLatencyWebview: (NSNumber *)value withTags: (NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_token_availability_latency_webview"
                       value: value
                        tags: tags];
}

+ (instancetype)newTokenResolutionRequestLatency: (NSNumber *)value withTags: (NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_token_resolution_request_latency"
                       value: value
                        tags: tags];
}

+ (instancetype)newEmergencySwitchOffWithTags: (NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_emergency_switch_off"
                       value: nil
                        tags: tags];
}

+ (instancetype)newDeviceInfoCollectionLatency: (NSNumber *)value withTags: (nullable NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_device_info_collection_latency"
                       value: value
                        tags: tags];
}

+ (instancetype)newDeviceInfoCompressionLatency: (NSNumber *)value withTags: (nullable NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_device_info_compression_latency"
                       value: value
                        tags: tags];
}

+ (instancetype)newNativeGeneratedTokenAvailableWithTags: (nullable NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_generated_token_available"
                       value: nil
                        tags: tags];
}

+ (instancetype)newNativeGeneratedTokenNullWithTags: (nullable NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_generated_token_null"
                       value: nil
                        tags: tags];
}

+ (instancetype)newAsyncTokenNullWithTags: (nullable NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_async_token_null"
                       value: nil
                        tags: tags];
}

@end
