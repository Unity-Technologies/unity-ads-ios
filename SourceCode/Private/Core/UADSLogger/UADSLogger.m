
#import "UADSLogger.h"
#import "UADSTools.h"

@interface UADSConsoleLogger ()
@property (nonatomic, strong) NSArray<NSString *> *allowedSystems;
@end

@implementation UADSConsoleLogger
+ (instancetype)newWithSystemList: (NSArray<NSString *> *)allowedList  {
    UADSConsoleLogger *logger = [self new];

    logger.allowedSystems = allowedList;
    return logger;
}

- (void)logRecord: (nonnull id<UADSLogRecord>)record {
    if (![self shouldLogEvent: record]) {
        return;
    }

    [self logString: [self formattedStringForEvent: record]];
}

- (void)logString: (NSString *)string {
    dispatch_on_main(^{
        NSLog(@"%@\n", string);
    });
}

- (NSString *)formattedStringForEvent: (id<UADSLogRecord>)record {
    /**
               <HEADER>
       System:
       Level:
       Message:
     */

    NSMutableString *output = [NSMutableString stringWithFormat: @"\r🚦UNITY ADS LOGS: \r"];

    [output appendFormat: @"System: %@\r", record.system];
    [output appendFormat: @"Level: %@\r", uads_logLevelToString(record.level)];

    [output appendFormat: @"Message: %@", record.message];
    return output;
}

- (BOOL)shouldLogEvent: (id<UADSLogRecord>)record {
    BOOL isInRange = record.level <= _currentLogLevel;
    BOOL categoryIsWhiteListed = _allowedSystems.count == 0 || [_allowedSystems containsObject: record.system];

    return isInRange && categoryIsWhiteListed;
}

@end
