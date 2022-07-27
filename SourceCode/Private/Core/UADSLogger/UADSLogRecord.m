#import "UADSLogRecord.h"

NSString * uads_logLevelToString(UADSLogLevel type) {
    switch (type) {
        case kUADSLogLevelWarning:
            return @"Warning";

        case kUADSLogLevelInfo:
            return @"Info";

        case kUADSLogLevelError:
            return @"Error";

        case kUADSLogLevelTrace:
            return @"Trace";

        case kUADSLogLevelFatal:
            return @"Fatal";

        case kUADSLogLevelDebug:
            return @"Debug";

        default:
            return @"";
    }
}

@interface UADSLogRecordBase ()
@property (nonatomic, copy) NSString *system;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) UADSLogLevel level;
@end

@implementation UADSLogRecordBase
+ (instancetype)newWithSystem: (NSString *)system
                   andMessage: (NSString *)message
                     andLevel: (UADSLogLevel)level {
    UADSLogRecordBase *event = [self new];

    event.system = system;
    event.message = message;
    event.level = level;
    return event;
}

+ (instancetype)newWarning: (NSString *)message system: (NSString *)system {
    return [self newWithSystem: system
                    andMessage: message
                      andLevel: kUADSLogLevelWarning];
}

+ (instancetype)newInfo: (NSString *)message system: (NSString *)system {
    return [self newWithSystem: system
                    andMessage: message
                      andLevel: kUADSLogLevelInfo];
}

+ (instancetype)newError: (NSString *)message system: (NSString *)system {
    return [self newWithSystem: system
                    andMessage: message
                      andLevel: kUADSLogLevelError];
}

+ (instancetype)newTrace: (NSString *)message system: (NSString *)system {
    return [self newWithSystem: system
                    andMessage: message
                      andLevel: kUADSLogLevelTrace];
}

@end

@implementation UADSDurationLogRecord
+ (instancetype)newWith: (NSString *)message
                 system: (NSString *)system
               duration: (CFTimeInterval)duration {
    NSString *logMessage = [NSString stringWithFormat: @"[%@] duration: %f", message, duration];

    return [self newTrace: logMessage
                   system: system];
}

@end
