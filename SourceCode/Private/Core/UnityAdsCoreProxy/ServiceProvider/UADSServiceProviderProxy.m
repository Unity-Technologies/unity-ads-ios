#import "UADSServiceProviderProxy.h"
#import "NSInvocation+Convenience.h"

static NSString *const SHARED_INSTANCE_SELECTOR = @"shared";
static NSString *const MAIN_NETWORK_LAYER_KVO = @"mainNetworkLayer";
static NSString *const SAVE_CONFIGURATION_SELECTOR = @"saveSDKConfigFrom:";

@implementation UADSServiceProviderProxy
+ (NSString *)className {
    return @"UnityAds.ServiceProviderObjCBridge";
}

+ (instancetype)shared {
    id object = [NSInvocation uads_invokeWithReturnedUsingMethod: SHARED_INSTANCE_SELECTOR
                                                       classType: [self getClass]
                                                          target: nil
                                                            args: @[]];

    return [self getProxyWithObject: object];
}

- (UADSCommonNetworkProxy *)mainNetworkLayer {
    id obj = [self valueForKey: MAIN_NETWORK_LAYER_KVO];
    UADSCommonNetworkProxy *proxy = [UADSCommonNetworkProxy getProxyWithObject: obj];

    return proxy;
}

- (void)saveConfiguration: (NSDictionary *)configDictionary {
    if (configDictionary) {
        [self callInstanceMethod: SAVE_CONFIGURATION_SELECTOR
                            args: @[configDictionary]];
    }
}

@end
