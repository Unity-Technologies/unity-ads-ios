#import "UADSTimerWithAppLifeCycle.h"

@interface UADSTimerWithAppLifeCycle ()
@property (nonatomic, strong) id<UADSRepeatableTimer> original;
@property (nonatomic, strong) id<UADSAppLifeCycleNotificationCenter> notificationCenter;
@property (nonatomic, strong) NSString *listenerId;
@end

@implementation UADSTimerWithAppLifeCycle
+ (instancetype)defaultTimer {
    return [self timerWithOriginal: [UADSTimer new]
                         lifeCycleNotificationCenter: [UADSAppLifeCycleMediator new]];
}

+ (instancetype)timerWithOriginal: (id <UADSRepeatableTimer>)timer lifeCycleNotificationCenter: (id<UADSAppLifeCycleNotificationCenter>)notificationCenter {
    return [[UADSTimerWithAppLifeCycle alloc] initWithOriginal: timer
                                             lifeCycleListener: notificationCenter];
}

- (instancetype)initWithOriginal: (id <UADSRepeatableTimer>)timer lifeCycleListener: (id<UADSAppLifeCycleNotificationCenter>)listener {
    SUPER_INIT

        _original = timer;

    _notificationCenter = listener;
    [self subscribeForAppCycleEvents];

    return self;
}

- (void)dealloc {
    [_notificationCenter removeListener: _listenerId];
}

- (void)subscribeForAppCycleEvents {
    __weak typeof(self) weakSelf = self;
    _listenerId = [_notificationCenter addEventsListenerWithDidBecomeActive:^{
        [weakSelf resume];
    }
                                                         didEnterBackground:^{
                                                             [weakSelf pause];
                                                         }];
}

- (void)invalidate {
    [_original invalidate];
}

- (void)pause {
    [_original pause];
}

- (void)resume {
    [_original resume];
}

- (void)scheduleWithTimeInterval: (NSTimeInterval)ti repeatCount: (NSInteger)repeat block: (nonnull void (^)(NSInteger))block {
    [_original scheduleWithTimeInterval: ti
                            repeatCount: repeat
                                  block: block];
}

@end
