#import "NSDate+Mock.h"

static BOOL mockDate = true;

@implementation NSDate (Mock)
+ (instancetype)date {
    if (mockDate) {
        return [NSDate dateWithTimeIntervalSince1970: 12345];
    }

    return [NSDate dateWithTimeIntervalSinceNow: 0];
}

+ (NSTimeInterval)currentTimeInterval {
    return [[NSDate date] timeIntervalSince1970];
}

+ (void)setMockDate: (BOOL)mock {
    mockDate = mock;
}

@end
