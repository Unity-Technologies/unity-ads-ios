#import "UADSPrivacyMetrics.h"

@implementation UADSPrivacyMetrics

+ (instancetype)newPrivacyRequestSuccessLatency: (nullable NSDictionary<NSString *, NSString *> *)tags; {
    return [self newWithName: @"native_privacy_success_latency"
                       value: nil
                        tags: tags];
}

+ (instancetype)newPrivacyRequestErrorLatency: (nullable NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_privacy_failure_latency"
                       value: nil
                        tags: tags];
}

@end
