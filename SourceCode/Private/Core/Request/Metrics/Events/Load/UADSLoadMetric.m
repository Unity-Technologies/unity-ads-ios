#import "UADSLoadMetric.h"

@implementation UADSLoadMetric

+ (instancetype)newEventStarted: (UADSEventHandlerType)type tags: (nullable NSDictionary<NSString *, NSString *> *)tags {
    NSString *metricName;
    NSMutableDictionary *metricTags = [NSMutableDictionary dictionaryWithDictionary:tags];
    switch (type) {
        case kUADSEventHandlerTypeLoadModule:
            metricName = @"native_load_started";
            metricTags[@"type"] = @"video";
            break;
        case kUADSEventHandlerTypeBannerLoadModule:
            metricName = @"native_load_started";
            metricTags[@"type"] = @"banner";
            break;
        case kUADSEventHandlerTypeShowModule:
            metricName = @"native_show_started";
            break;
    }
    return [self newWithName: metricName
                       value: nil
                        tags: metricTags];
}

+ (instancetype)newEventSuccess: (UADSEventHandlerType)type time: (nullable NSNumber *)value tags: (nullable NSDictionary<NSString *, NSString *> *)tags; {
    NSString *metricName;
    NSMutableDictionary *metricTags = [NSMutableDictionary dictionaryWithDictionary:tags];
    switch (type) {
        case kUADSEventHandlerTypeLoadModule:
            metricName = @"native_load_time_success";
            metricTags[@"type"] = @"video";
            break;
        case kUADSEventHandlerTypeBannerLoadModule:
            metricName = @"native_load_time_success";
            metricTags[@"type"] = @"banner";
            break;
        case kUADSEventHandlerTypeShowModule:
            metricName = @"native_show_time_success";
            break;
    }
    return [self newWithName: metricName
                       value: value
                        tags: metricTags];
}

+ (instancetype)newEventFailed: (UADSEventHandlerType)type time: (nullable NSNumber *)value tags: (nullable NSDictionary<NSString *, NSString *> *)tags {
    NSString *metricName;
    NSMutableDictionary *metricTags = [NSMutableDictionary dictionaryWithDictionary:tags];
    switch (type) {
        case kUADSEventHandlerTypeLoadModule:
            metricName = @"native_load_time_failure";
            metricTags[@"type"] = @"video";
            break;
        case kUADSEventHandlerTypeBannerLoadModule:
            metricName = @"native_load_time_failure";
            metricTags[@"type"] = @"banner";
            break;
        case kUADSEventHandlerTypeShowModule:
            metricName = @"native_show_time_failure";
            break;
    }
    return [self newWithName: metricName
                       value: value
                        tags: metricTags];
}

@end
