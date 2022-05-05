#import "GMAAdMetaData.h"

@implementation GMAAdMetaData

- (NSTimeInterval)videoLengthInSeconds {
    return ([_videoLength intValue] >= 1000) ? [_videoLength doubleValue] / 1000 : [_videoLength doubleValue];
}

@end
