#import "UADSCurrentTimestampBase.h"

@implementation UADSCurrentTimestampBase

- (CFTimeInterval)currentTimestamp {
    return [[NSDate date] timeIntervalSince1970];
}

- (NSNumber *)msDurationFrom: (CFTimeInterval)time {
    CFTimeInterval duration = self.currentTimestamp - time;

    return [NSNumber numberWithInt: round(duration * 1000)];
}

@end
