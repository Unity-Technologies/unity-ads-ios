#import "UADSCurrentTimestampBase.h"
#import "UIKit/UIKit.h"

@implementation UADSCurrentTimestampBase

- (CFTimeInterval)currentTimestamp {
    return CACurrentMediaTime();
}

- (NSNumber *)msDurationFrom: (CFTimeInterval)time {
    CFTimeInterval duration = self.currentTimestamp - time;

    return [NSNumber numberWithInt: round(duration * 1000)];
}

- (NSTimeInterval)epochSeconds {
    return [[NSDate date] timeIntervalSince1970];
}

@end
