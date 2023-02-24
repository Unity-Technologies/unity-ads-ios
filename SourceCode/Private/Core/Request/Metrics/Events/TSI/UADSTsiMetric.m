#import "UADSTsiMetric.h"

@implementation UADSTsiMetric

+ (instancetype)newMissingToken {
    return [self newWithName: @"native_missing_token"
                       value: nil
                        tags: nil];
}

+ (instancetype)newMissingStateId {
    return [self newWithName: @"native_missing_state_id"
                       value: nil
                        tags: nil];
}

+ (instancetype)newMissingGameSessionId {
    return [self newWithName: @"native_missing_game_session_id"
                       value: nil
                        tags: nil];
}

+ (instancetype)newInitTimeSuccess: (NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_initialization_time_success"
                       value: value
                        tags: tags];
}

+ (instancetype)newInitTimeFailure: (NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_initialization_time_failure"
                       value: value
                        tags: tags];
}

+ (instancetype)newInitStarted {
    return [self newWithName: @"native_initialization_started"
                       value: nil
                        tags: nil];
}

+ (instancetype)newTokenAvailabilityLatencyConfig: (NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_token_availability_latency_config"
                       value: value
                        tags: tags];
}

+ (instancetype)newTokenAvailabilityLatencyWebview: (NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_token_availability_latency_webview"
                       value: value
                        tags: tags];
}

+ (instancetype)newTokenResolutionRequestLatency: (NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_token_resolution_request_latency"
                       value: value
                        tags: tags];
}

+ (instancetype)newTokenResolutionRequestFailureLatency: (NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_token_resolution_request_latency_failure"
                       value: nil
                        tags: tags];
}

+ (instancetype)newDeviceInfoCollectionLatency: (NSNumber *)value {
    return [self newWithName: @"native_device_info_collection_latency"
                       value: value
                        tags: nil];
}

+ (instancetype)newDeviceInfoCompressionLatency: (NSNumber *)value {
    return [self newWithName: @"native_device_info_compression_latency"
                       value: value
                        tags: nil];
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

+ (instancetype)newAsyncTokenTokenAvailableWithTags: (nullable NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_async_token_available"
                       value: nil
                        tags: tags];
}

@end
