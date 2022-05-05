#import "UADSArrayScheduledStream.h"

@interface UADSArrayScheduledStream ()
@property (nonatomic, strong) id<UADSRepeatableTimer> timer;
@end

@implementation UADSArrayScheduledStream

+ (instancetype)scheduledStreamWithArray: (NSArray *)array totalTime: (NSTimeInterval)ti timer: (id<UADSRepeatableTimer>)timer block: (void (^)(id item, NSInteger index))block {
    UADSArrayScheduledStream *stream = [UADSArrayScheduledStream new];

    stream.timer = timer;
    __weak typeof(stream) weakStream = stream;
    [stream.timer scheduleWithTimeInterval: ti / array.count
                               repeatCount: array.count
                                     block:^(NSInteger index) {
                                         if (index < array.count) {
                                             block(array[index], index);
                                         }

                                         if (index == array.count - 1) {
                                             [weakStream invalidate];
                                         }
                                     }];

    return stream;
}

- (void)invalidate {
    [self.timer invalidate];
    self.timer = nil;
}

@end
