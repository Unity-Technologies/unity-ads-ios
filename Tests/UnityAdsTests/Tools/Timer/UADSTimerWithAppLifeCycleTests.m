#import <XCTest/XCTest.h>
#import "UADSRepeatableTimerMock.h"
#import "UADSTimerWithAppLifeCycle.h"
#import "NSDate+Mock.h"
#import "XCTestCase+Convenience.h"

@interface UADSAppLifeCycleNotificationCenterMock : NSObject <UADSAppLifeCycleNotificationCenter>
@property (nonatomic, strong) UADSVoidClosure didBecomeActiveBlock;
@property (nonatomic, strong) UADSVoidClosure didEnterBackgroundBlock;

- (void)triggerDidBecomeActive;
- (void)triggerDidEnterBackground;
@end

@implementation UADSAppLifeCycleNotificationCenterMock


- (nonnull NSString *)addEventsListenerWithDidBecomeActive: (nonnull UADSVoidClosure)didBecomeActive didEnterBackground: (nonnull UADSVoidClosure)didEnterBackground {
    _didBecomeActiveBlock = didBecomeActive;
    _didEnterBackgroundBlock = didEnterBackground;

    return @"";
}

- (void)removeListener: (nonnull NSString *)identifier {
}

- (void)triggerDidBecomeActive {
    _didBecomeActiveBlock();
}

- (void)triggerDidEnterBackground {
    _didEnterBackgroundBlock();
}

@end

@interface UADSTimerWithAppLifeCycleTests : XCTestCase

@end

@implementation UADSTimerWithAppLifeCycleTests

- (void)test_timer_observes_life_cycle_events {
    UADSRepeatableTimerMock *originalMock = [[UADSRepeatableTimerMock alloc] init];
    UADSAppLifeCycleNotificationCenterMock *notificationCenterMock = [[UADSAppLifeCycleNotificationCenterMock alloc] init];

    UADSTimerWithAppLifeCycle *timer = [UADSTimerWithAppLifeCycle timerWithOriginal: originalMock
                                                        lifeCycleNotificationCenter         : notificationCenterMock];

    [notificationCenterMock triggerDidEnterBackground];
    XCTAssertEqual(originalMock.pausedCalled, 1);
    [notificationCenterMock triggerDidBecomeActive];
    XCTAssertEqual(originalMock.resumeCalled, 1);
    timer = nil;
    [notificationCenterMock triggerDidEnterBackground];
    XCTAssertEqual(originalMock.pausedCalled, 1);
    [notificationCenterMock triggerDidBecomeActive];
    XCTAssertEqual(originalMock.resumeCalled, 1);
}

- (void)test_timer_does_not_crash_if_not_scheduled {
    UADSTimer *original = [UADSTimer new];
    UADSAppLifeCycleNotificationCenterMock *notificationCenterMock = [[UADSAppLifeCycleNotificationCenterMock alloc] init];

    UADSTimerWithAppLifeCycle *timer = [UADSTimerWithAppLifeCycle timerWithOriginal: original
                                                        lifeCycleNotificationCenter         : notificationCenterMock];

    [notificationCenterMock triggerDidEnterBackground];
    [notificationCenterMock triggerDidBecomeActive];
    [NSThread sleepForTimeInterval: 1.0];
    XCTAssertNotNil(timer);
}

@end
