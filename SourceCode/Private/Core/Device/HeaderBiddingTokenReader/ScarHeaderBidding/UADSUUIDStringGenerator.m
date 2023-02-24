#import "UADSUUIDStringGenerator.h"

@implementation UADSUUIDStringGenerator

- (NSString*)generateId {
    return [NSUUID new].UUIDString;
}

@end
