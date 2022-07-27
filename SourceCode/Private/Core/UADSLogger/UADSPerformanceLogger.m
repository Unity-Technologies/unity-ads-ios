#import "UADSPerformanceLogger.h"
#import "NSDate+NSNumber.h"
#import "UADSPerformanceMeasurer.h"
#import "UADSCurrentTimestampBase.h"

@interface UADSPerformanceLoggerBase ()
@property (nonatomic, strong) id<UADSLogger>logger;
@property (nonatomic, strong) UADSPerformanceMeasurer *measurer;
@end

@implementation UADSPerformanceLoggerBase
+ (instancetype)newWithLogger: (id<UADSLogger>)logger {
    UADSPerformanceLoggerBase *base = [UADSPerformanceLoggerBase new];

    base.measurer = [UADSPerformanceMeasurer newWithTimestampReader: [UADSCurrentTimestampBase new]];
    base.logger = logger;
    return base;
}

- (void)startMeasureForSystem: (nonnull NSString *)system {
    [self.measurer startMeasureForSystem: system];
}

- (void)endMeasureForSystem: (nonnull NSString *)system {
    [self.measurer startMeasureForSystem: system];
}

- (void)calculateDurationAndSendForSystem: (nonnull NSString *)system  {
    if (![self.measurer measureStartedForSystem: system]) {
        [self logStartNotFoundForSystem: system];
        return;
    }

    NSNumber *duration = [self.measurer endMeasureForSystem: system];

    UADSDurationLogRecord *durationRecord = [UADSDurationLogRecord newWith: @"Performed for "
                                                                    system: system
                                                                  duration: [duration intValue]];

    [_logger logRecord: durationRecord];
}

- (void)logStartNotFoundForSystem: (NSString *)system {
    NSString *message = @"Start time wasn't found. Cannot calculate the duration";
    UADSLogRecordBase *record = [UADSLogRecordBase newWarning: message
                                                       system: system];

    [_logger logRecord: record];
}

@end
