#import "UADSCorePresenceChecker.h"

@implementation UADSCorePresenceChecker
+ (Boolean)isPresent {
    return NSClassFromString(@"UnityAds.ServiceProviderObjCBridge") != nil;
}

@end
