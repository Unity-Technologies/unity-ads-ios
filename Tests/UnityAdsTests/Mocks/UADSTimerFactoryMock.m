#import "UADSTimerFactoryMock.h"
#import "UADSTools.h"
@implementation UADSTimerFactoryMock

- (instancetype)init {
    SUPER_INIT;
    _timerMocks = [NSMutableArray array];
    return self;
}

- (nonnull id<UADSRepeatableTimer>)timerWithAppLifeCycle {
    UADSRepeatableTimerMock *mock = [UADSRepeatableTimerMock new];

    [self.timerMocks addObject: mock];
    return mock;
}

- (UADSRepeatableTimerMock *)lastTimerMock {
    return self.timerMocks.lastObject;
}

@end
