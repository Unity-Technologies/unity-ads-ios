#import <Foundation/Foundation.h>
#import "UADSTimer.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSRepeatableTimerMock : NSObject <UADSRepeatableTimer>
@property (nonatomic, assign) NSTimeInterval totalTime;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) BOOL invalidateCalled;
@property (nonatomic, assign) NSInteger pausedCalled;
@property (nonatomic, assign) NSInteger resumeCalled;
- (void)fire;
- (void)fire: (NSInteger)times;
@end

NS_ASSUME_NONNULL_END
