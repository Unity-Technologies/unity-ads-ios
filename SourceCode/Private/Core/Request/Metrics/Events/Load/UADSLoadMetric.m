#import "UADSLoadMetric.h"

@implementation UADSLoadMetric

+ (instancetype)newEventStarted: (UADSEventHandlerType)type tags: (nullable NSDictionary<NSString *, NSString *> *)tags; {
    switch (type) {
        case kUADSEventHandlerTypeLoadModule:
            return [self newWithName: @"native_load_started"
                               value: nil
                                tags: tags];

        case kUADSEventHandlerTypeShowModule:
            return [self newWithName: @"native_show_started"
                               value: nil
                                tags: tags];
    }
}

+ (instancetype)newEventSuccess: (UADSEventHandlerType)type time: (nullable NSNumber *)value tags: (nullable NSDictionary<NSString *, NSString *> *)tags; {
    switch (type) {
        case kUADSEventHandlerTypeLoadModule:
            return [self newWithName: @"native_load_time_success"
                               value: value
                                tags: tags];

        case kUADSEventHandlerTypeShowModule:
            return [self newWithName: @"native_show_time_success"
                               value: value
                                tags: tags];
    }
}

+ (instancetype)newEventFailed: (UADSEventHandlerType)type time: (nullable NSNumber *)value tags: (nullable NSDictionary<NSString *, NSString *> *)tags {
    switch (type) {
        case kUADSEventHandlerTypeLoadModule:
            return [self newWithName: @"native_load_time_failure"
                               value: value
                                tags: tags];

        case kUADSEventHandlerTypeShowModule:
            return [self newWithName: @"native_show_time_failure"
                               value: value
                                tags: tags];
    }
}

@end
