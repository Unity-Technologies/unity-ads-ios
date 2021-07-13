#import "GMAVersionReaderV8.h"

static NSString *const kGMASDKVersionKey =  @"sdkVersion";

@implementation GMAVersionReaderV8

+ (NSArray<NSString *> *)requiredKeysForKVO {
    return @[kGMASDKVersionKey];
}

+ (NSString *)sdkVersion {
    return [self.sharedInstance sdkVersion];
}

- (NSString *)sdkVersion {
    return [self.proxyObject valueForKey: kGMASDKVersionKey];
}

@end
