#import "UADSUniqueIdGeneratorMock.h"

@implementation UADSUniqueIdGeneratorMock

- (NSString *)generateId {
    return self.expectedValue;
}

@end
