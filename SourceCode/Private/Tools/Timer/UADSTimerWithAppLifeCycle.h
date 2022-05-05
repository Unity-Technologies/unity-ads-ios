#import <Foundation/Foundation.h>
#import "UADSTimer.h"
#import "UADSAppLifeCycleNotificationCenter.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSTimerWithAppLifeCycle : NSObject <UADSRepeatableTimer>
+ (instancetype)defaultTimer;
+ (instancetype)timerWithOriginal: (id <UADSRepeatableTimer>)timer lifeCycleNotificationCenter: (id<UADSAppLifeCycleNotificationCenter>)notificationCenter;
@end

NS_ASSUME_NONNULL_END
