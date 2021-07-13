#import "NSDate + NSNumber.h"

@implementation NSDate (NSNumber)
- (NSNumber *)uads_timeIntervalSince1970 {
    return [NSNumber numberWithDouble: self.timeIntervalSince1970];
}

@end
