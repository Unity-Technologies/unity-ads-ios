#import "UADSCurrentTimestampMock.h"

@implementation UADSCurrentTimestampMock

- (CFTimeInterval)currentTimestamp {
    @synchronized (self) {
        self.currentTime += 1.2346;
    }
    return self.currentTime;
}

- (NSNumber *)msDurationFrom: (CFTimeInterval)time {
    CFTimeInterval duration = self.currentTimestamp - time;

    return [NSNumber numberWithInt: round(duration * 1000)];
}

- (NSTimeInterval)epochSeconds {
    self.epochCurrentTime += 1.2346;
    return self.epochCurrentTime;
}

+ (NSNumber *)mockedDuration {
    return @(1235);
}

@end
