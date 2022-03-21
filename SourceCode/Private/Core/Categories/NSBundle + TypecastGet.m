#import "NSBundle + TypecastGet.h"
#import "UADSTools.h"

@implementation NSBundle (TypecastGet)
- (NSString *)getStringValueForKey: (NSString *)key {
    id obj = [self objectForInfoDictionaryKey: key];

    return typecast(obj, [NSString class]);
}

+ (NSString *)getFromMainBundleValueForKey: (NSString *)key {
    return [[self mainBundle] getStringValueForKey: key];
}

+ (NSString *)getBuiltSDKVersion {
    return [self getFromMainBundleValueForKey: @"DTSDKName"];
}

@end
