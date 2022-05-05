#import <Foundation/Foundation.h>
#import "UADSTimer.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSArrayScheduledStream : NSObject

+ (instancetype)scheduledStreamWithArray: (NSArray *)array totalTime: (NSTimeInterval)ti timer: (id<UADSRepeatableTimer>)timer block: (void (^)(id item, NSInteger index))block;
- (void)        invalidate;
@end

NS_ASSUME_NONNULL_END
