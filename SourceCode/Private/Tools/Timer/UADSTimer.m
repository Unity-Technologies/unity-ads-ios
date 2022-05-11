#import "UADSTimer.h"
#import "UADSTools.h"

@interface UADSTimer ()
@property (nonatomic, strong) NSArray *timeIntervals;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval remainingTime;
@property (nonatomic, copy) void (^ timerBlock)(NSInteger);

@end

@implementation UADSTimer

- (void)scheduleWithTimeInterval: (NSTimeInterval)ti repeatCount: (NSInteger)repeat block: (void (^)(NSInteger index))block {
    NSMutableArray *timeIntervals = [NSMutableArray array];

    for (int i = 0; i < repeat; i++) {
        [timeIntervals addObject: @(ti)];
    }

    [self scheduleWithTimeIntervals: timeIntervals
                              block: block];
}

- (void)scheduleWithTimeIntervals: (NSArray *)ti block: (void (^)(NSInteger index))block {
    _timeIntervals = ti;
    _timerBlock = block;
    _currentIndex = 0;

    [self invalidate];
    [self scheduleTimerForIndex: 0];
}

- (void)scheduleTimerForIndex: (NSInteger)index {
    if (index < 0 || index >= self.timeIntervals.count) {
        return;
    }

    NSTimeInterval ti = [[self.timeIntervals objectAtIndex: index] doubleValue];

    [self scheduleTimerWithTimeInterval: ti];
}

- (void)scheduleTimerWithTimeInterval: (NSTimeInterval)ti {
    dispatch_on_main_sync(^{
        self.timer = [NSTimer scheduledTimerWithTimeInterval: ti
                                                      target: self
                                                    selector: @selector(timesUp:)
                                                    userInfo: nil
                                                     repeats: NO];
    });
}

- (void)timesUp: (NSTimer *)timer {
    [self invalidate];

    self.timerBlock(self.currentIndex);

    self.currentIndex += 1;
    [self scheduleTimerForIndex: self.currentIndex];
}

- (void)invalidate {
    dispatch_on_main_sync(^{
        [self.timer invalidate];
        self.timer = nil;
    });
}

- (void)pause {
    if (self.isValid && self.wasInitialized) {
        self.remainingTime = [self.timer.fireDate timeIntervalSinceNow];
        [self invalidate];
    }
}

- (void)resume {
    if (!self.isValid && self.wasInitialized) {
        [self scheduleTimerWithTimeInterval: self.remainingTime];
    }
}

- (BOOL)isValid {
    return self.timer && self.timer.isValid;
}

- (BOOL)wasInitialized {
    return self.timeIntervals && self.timerBlock;
}

@end
