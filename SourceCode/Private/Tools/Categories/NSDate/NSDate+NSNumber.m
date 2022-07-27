#import "NSDate+NSNumber.h"

@implementation NSDate (NSNumber)
- (NSNumber *)uads_timeIntervalSince1970 {
    return [NSNumber numberWithDouble: self.timeIntervalSince1970];
}

@end


@implementation NSDate (Convenience)
+ (NSTimeInterval)uads_currentTimestampSince1970 {
    return [[self date] timeIntervalSince1970];
}

@end
