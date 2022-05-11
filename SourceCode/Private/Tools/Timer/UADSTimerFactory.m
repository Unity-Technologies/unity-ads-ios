#import "UADSTimerFactory.h"
#import "UADSTimerWithAppLifeCycle.h"

@implementation UADSTimerFactoryBase

- (nonnull id<UADSRepeatableTimer>)timerWithAppLifeCycle {
    return [UADSTimerWithAppLifeCycle defaultTimer];
}

@end
