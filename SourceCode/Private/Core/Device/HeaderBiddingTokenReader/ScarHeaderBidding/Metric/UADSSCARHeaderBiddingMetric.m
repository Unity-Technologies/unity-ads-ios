#import "UADSSCARHeaderBiddingMetric.h"

@implementation UADSSCARHeaderBiddingMetric

+ (instancetype)newScarFetchStarted {
    return [self newWithName: @"native_hb_signals_fetch_start"
                       value: nil
                        tags: nil];
}

+ (instancetype)newScarFetchTimeSuccess: (NSNumber *)value {
    return [self newWithName: @"native_hb_signals_fetch_success"
                       value: value
                        tags: nil];
}

+ (instancetype)newScarFetchTimeFailure: (NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_hb_signals_fetch_failure"
                       value: value
                        tags: tags];
}

+ (instancetype)newScarSendStarted {
    return [self newWithName: @"native_hb_signals_upload_start"
                       value: nil
                        tags: nil];
}

+ (instancetype)newScarSendTimeSuccess: (NSNumber *)value {
    return [self newWithName: @"native_hb_signals_upload_success"
                       value: value
                        tags: nil];
}

+ (instancetype)newScarSendTimeFailure: (NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags {
    return [self newWithName: @"native_hb_signals_upload_failure"
                       value: value
                        tags: tags];
}

@end
