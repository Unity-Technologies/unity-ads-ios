#import "UADSSCARHeaderBiddingMetric.h"

@implementation UADSSCARHeaderBiddingMetric

+ (instancetype)newScarFetchStartedWithIsAsync:(BOOL)isAsync {
    return [self newWithName: isAsync ? @"native_hb_signals_async_fetch_start" : @"native_hb_signals_sync_fetch_start"
                       value: nil
                        tags: nil];
}

+ (instancetype)newScarFetchTimeSuccess: (NSNumber *)value isAsync:(BOOL)isAsync {
    return [self newWithName: isAsync ? @"native_hb_signals_async_fetch_success" : @"native_hb_signals_sync_fetch_success"
                       value: value
                        tags: nil];
}

+ (instancetype)newScarFetchTimeFailure: (NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags isAsync:(BOOL)isAsync {
    return [self newWithName: isAsync ? @"native_hb_signals_async_fetch_failure" : @"native_hb_signals_sync_fetch_failure"
                       value: value
                        tags: tags];
}

+ (instancetype)newScarSendStartedWithIsAsync:(BOOL)isAsync {
    return [self newWithName: isAsync ? @"native_hb_signals_async_upload_start" : @"native_hb_signals_sync_upload_start"
                       value: nil
                        tags: nil];
}

+ (instancetype)newScarSendTimeSuccess: (NSNumber *)value isAsync:(BOOL)isAsync {
    return [self newWithName: isAsync ? @"native_hb_signals_async_upload_success" : @"native_hb_signals_sync_upload_success"
                       value: value
                        tags: nil];
}

+ (instancetype)newScarSendTimeFailure: (NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags isAsync:(BOOL)isAsync {
    return [self newWithName: isAsync ? @"native_hb_signals_async_upload_failure" : @"native_hb_signals_sync_upload_failure"
                       value: value
                        tags: tags];
}

@end
