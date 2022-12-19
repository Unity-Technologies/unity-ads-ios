#import "UADSServiceProviderProxy.h"
#import "NSInvocation+Convenience.h"

static NSString *const INIT_INSTANCE_SELECTOR = @"init:";
static NSString *const SHARED_INSTANCE_SELECTOR = @"shared";
static NSString *const SDK_INITIALIZER_SELECTOR = @"sdkInitializerWithFactory:";
static NSString *const MAIN_NETWORK_LAYER_KVO = @"nativeNetworkLayer";
static NSString *const METRICS_NETWORK_LAYER_KVO = @"nativeMetricsNetworkLayer";
static NSString *const SAVE_CONFIGURATION_SELECTOR = @"saveSDKConfigFrom:";
static NSString *const GET_CONFIGURATION_SELECTOR = @"configDictionary";
@implementation UADSServiceProviderProxy
+ (NSString *)className {
    return @"UnityAds.ServiceProviderObjCBridge";
}

+ (UADSServiceProviderProxy *)newWithDeviceInfoProvider:(id)deviceInfoProvider {
    UADSServiceProviderProxy *proxy = [self getInstanceUsingMethod: INIT_INSTANCE_SELECTOR args: @[deviceInfoProvider]];
    return proxy;
}

- (UADSCommonNetworkProxy *)nativeNetworkLayer {
    id obj = [self valueForKey: MAIN_NETWORK_LAYER_KVO];
    UADSCommonNetworkProxy *proxy = [UADSCommonNetworkProxy getProxyWithObject: obj];

    return proxy;
}

- (UADSCommonNetworkProxy *)nativeMetricsNetworkLayer {
    id obj = [self valueForKey: METRICS_NETWORK_LAYER_KVO];
    UADSCommonNetworkProxy *proxy = [UADSCommonNetworkProxy getProxyWithObject: obj];
    return proxy;
}

- (UADSSDKInitializerProxy *)sdkInitializerWithFactory:(USRVInitializeStateFactory *)factory {
    id obj = [self callInstanceMethodWithReturn: SDK_INITIALIZER_SELECTOR args: @[factory]];
    return [UADSSDKInitializerProxy getProxyWithObject: obj];
}

- (void)saveConfiguration: (NSDictionary *)configDictionary {
    if (configDictionary) {
        [self callInstanceMethod: SAVE_CONFIGURATION_SELECTOR
                            args: @[configDictionary]];
    }
}


@end
