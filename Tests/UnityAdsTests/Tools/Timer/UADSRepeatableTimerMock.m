#import "UADSRepeatableTimerMock.h"

@interface UADSRepeatableTimerMock ()
@property (nonatomic, copy) void (^ timerBlock)(NSInteger);
@property (nonatomic, assign) int currentIndex;
@end

@implementation UADSRepeatableTimerMock

- (void)invalidate {
    self.invalidateCalled = true;
}

- (void)scheduleWithTimeInterval: (NSTimeInterval)ti repeatCount: (NSInteger)repeat block: (nonnull void (^)(NSInteger))block {
    self.timerBlock = block;
    self.totalTime = ti;
    self.count = repeat;
}

- (void)pause {
    self.pausedCalled += 1;
}

- (void)resume {
    self.resumeCalled += 1;
}

- (void)fire {
    self.timerBlock(self.currentIndex);
    self.currentIndex += 1;
}

- (void)fire: (NSInteger)times {
    for (int i = 0; i < times; i++) {
        [self fire];
    }
}

@end
