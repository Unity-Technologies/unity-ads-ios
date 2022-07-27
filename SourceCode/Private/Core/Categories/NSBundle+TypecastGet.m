#import "NSBundle+TypecastGet.h"
#import "UADSTools.h"

@implementation NSBundle (TypecastGet)
- (NSString *)uads_getStringValueForKey: (NSString *)key {
    id obj = [self objectForInfoDictionaryKey: key];

    return typecast(obj, [NSString class]);
}

+ (NSString *)uads_getFromMainBundleValueForKey: (NSString *)key {
    return [[self mainBundle] uads_getStringValueForKey: key];
}

+ (NSString *)uads_getBuiltSDKVersion {
    return [self uads_getFromMainBundleValueForKey: @"DTSDKName"];
}

@end
