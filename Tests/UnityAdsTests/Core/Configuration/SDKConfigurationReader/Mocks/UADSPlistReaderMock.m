#import "UADSPlistReaderMock.h"

@implementation UADSPlistReaderMock
- (NSString *)uads_getStringValueForKey: (NSString *)key {
    return _expectedValue;
}

@end
