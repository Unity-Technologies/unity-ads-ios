#import "GADMobileAdsBridge.h"
#import "NSInvocation+Convenience.h"
#define SHARED_INSTANCE_SELECTOR @"sharedInstance"
@implementation GADMobileAdsBridge

+ (NSString *)className {
    return @"GADMobileAds";
}

+ (NSArray<NSString *> *)requiredSelectors {
    return @[SHARED_INSTANCE_SELECTOR];
}

+ (instancetype)sharedInstance {
    id object = [NSInvocation uads_invokeWithReturnedUsingMethod: SHARED_INSTANCE_SELECTOR
                                                       classType: [self getClass]
                                                          target: nil
                                                            args: @[]];

    return [self getProxyWithObject: object];
}

@end
