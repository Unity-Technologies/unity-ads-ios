#import "UADSTools.h"
#import "NSDate+NSNumber.h"

_Nullable id typecast(id obj, Class class) {
    if ([obj isKindOfClass: class]) {
        return obj;
    } else {
        return nil;
    }
}

void dispatch_on_main(dispatch_block_t block) {
    dispatch_async(dispatch_get_main_queue(), block);
}

void dispatch_on_main_sync(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

void uads_measure_duration_async(UADSDurationMeasureClosure blockToMeasure, UADSDurationClosure result) {
    __block CFTimeInterval start;
    UADSVoidClosure completion = ^() {
        CFTimeInterval end = [NSDate uads_currentTimestampSince1970];
        result(end - start);
    };

    start = [NSDate uads_currentTimestampSince1970];

    blockToMeasure(completion);
}

void uads_measure_duration_round_async(UADSDurationMeasureClosure blockToMeasure, UADSDurationNSNumberClosure result) {
    uads_measure_duration_async(blockToMeasure, ^(CFTimeInterval duration) {
        result([NSNumber numberWithInt: round(duration * 1000)]);
    });
}

CFTimeInterval uads_measure_duration_sync(UADSVoidClosure blockToMeasure) {
    CFTimeInterval start = [NSDate uads_currentTimestampSince1970];

    blockToMeasure();
    CFTimeInterval end = [NSDate uads_currentTimestampSince1970];
    CFTimeInterval duration = round((end - start) * 1000);

    return duration;
}

void uads_measure_performance_and_log(NSString *name, UADSVoidClosure blockToMeasure) {
    if ([USRVDeviceLog getLogLevel] == kUnityServicesLogLevelPerf) {
        NSLog(@"\n[PERFORMANCE DEBUG][%@]: %f", name, uads_measure_duration_sync(blockToMeasure));
    } else {
        blockToMeasure();
    }
}

NSString * uads_bool_to_string(BOOL value) {
    return value ? @"true" : @"false";
}
