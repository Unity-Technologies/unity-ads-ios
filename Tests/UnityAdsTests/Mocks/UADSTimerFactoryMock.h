#import <Foundation/Foundation.h>
#import "UADSTimerFactory.h"
#import "UADSRepeatableTimerMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSTimerFactoryMock : NSObject <UADSTimerFactory>
@property (nonatomic, strong) NSMutableArray *timerMocks;
- (UADSRepeatableTimerMock *)lastTimerMock;
@end

NS_ASSUME_NONNULL_END
