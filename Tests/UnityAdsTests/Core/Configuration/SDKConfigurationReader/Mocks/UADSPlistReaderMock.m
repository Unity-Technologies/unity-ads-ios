#import "UADSPlistReaderMock.h"

@implementation UADSPlistReaderMock
- (NSString *)getStringValueForKey: (NSString *)key {
    return _expectedValue;
}

@end
