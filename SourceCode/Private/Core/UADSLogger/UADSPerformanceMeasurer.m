#import "UADSPerformanceMeasurer.h"

@interface UADSPerformanceMeasurer ()
@property (nonatomic, strong) id<UADSCurrentTimestamp> timestampReader;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *startTimes;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation UADSPerformanceMeasurer

+ (instancetype)newWithTimestampReader: (id<UADSCurrentTimestamp>)timestampReader {
    UADSPerformanceMeasurer *base = [UADSPerformanceMeasurer new];

    base.timestampReader = timestampReader;
    base.queue = dispatch_queue_create("com.unity3d.ads.UADSPerformanceMeasurer", DISPATCH_QUEUE_SERIAL);
    base.startTimes = [NSMutableDictionary new];
    return base;
}

- (BOOL)measureStartedForSystem: (nonnull NSString *)system {
    __block BOOL started = false;

    dispatch_sync(_queue, ^{
        started = _startTimes[system] != nil;
    });
    return started;
}

- (void)startMeasureForSystem: (nonnull NSString *)system {
    dispatch_sync(_queue, ^{
        self.startTimes[system] = @(self.timestampReader.currentTimestamp);
    });
}

- (void)startMeasureForSystemIfNeeded: (nonnull NSString *)system {
    if (![self measureStartedForSystem: system]) {
        [self startMeasureForSystem: system];
    }
}

- (NSNumber *)endMeasureForSystem: (nonnull NSString *)system {
    __block NSNumber *duration;

    dispatch_sync(_queue, ^{
        duration = [self calculateDurationForSystem: system];
    });
    return duration;
}

- (NSNumber *)calculateDurationForSystem: (nonnull NSString *)system  {
    NSTimeInterval start = [_startTimes[system] doubleValue];

    if (!start) {
        return 0;
    }

    [_startTimes removeObjectForKey: system];
    return [self.timestampReader msDurationFrom: start];
}

@end
