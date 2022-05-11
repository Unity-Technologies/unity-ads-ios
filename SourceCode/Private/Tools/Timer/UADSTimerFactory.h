#import <Foundation/Foundation.h>

#import "UADSTimer.h"

NS_ASSUME_NONNULL_BEGIN

@protocol UADSTimerFactory <NSObject>
- (id<UADSRepeatableTimer>)timerWithAppLifeCycle;
@end

@interface UADSTimerFactoryBase : NSObject <UADSTimerFactory>

@end

NS_ASSUME_NONNULL_END
