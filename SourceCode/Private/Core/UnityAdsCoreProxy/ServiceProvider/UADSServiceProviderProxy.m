#import "UADSServiceProviderProxy.h"
#import "NSInvocation+Convenience.h"
#import "NSPrimitivesBox.h"

static NSString *const INIT_INSTANCE_SELECTOR = @"init:";
static NSString *const SHARED_INSTANCE_SELECTOR = @"shared";
static NSString *const SDK_INITIALIZER_SELECTOR = @"sdkInitializerWithFactory:";
static NSString *const MAIN_NETWORK_LAYER_KVO = @"nativeNetworkLayer";
static NSString *const METRICS_NETWORK_LAYER_KVO = @"nativeMetricsNetworkLayer";
static NSString *const SAVE_CONFIGURATION_SELECTOR = @"saveSDKConfigFrom:";
static NSString *const GET_CONFIGURATION_SELECTOR = @"configDictionary";
static NSString *const SET_DEBUG_MODE_SELECTOR = @"setDebugMode:";
static NSString *const CURRENT_STATE_KVO = @"currentState";
static NSString *const GAME_SESSION_ID_KVO = @"gameSessionId";
static NSString *const SESSION_ID_KVO = @"sessionId";
static NSString *const GET_TOKEN_SELECTOR = @"getToken:";


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

- (void)setDebugMode: (BOOL)isDebugMode {
    NSPrimitivesBox *box = [NSPrimitivesBox newWithBytes: &isDebugMode objCType: @encode(BOOL)];
    [self callInstanceMethod: SET_DEBUG_MODE_SELECTOR
                        args: @[box]];
}

- (InitializationState)currentState {
    NSNumber *state = [self callInstanceMethodWithReturn:CURRENT_STATE_KVO args:@[]];
    return state.intValue;
}

- (NSNumber *)gameSessionId {
    NSNumber *gameSessionId = [self callInstanceMethodWithReturn:GAME_SESSION_ID_KVO args:@[]];
    return gameSessionId;
}

- (NSString *)sessionId {
    return [self callInstanceMethodWithReturn:SESSION_ID_KVO args:@[]];
}


- (void)getToken:(UADSTokenCompletion)completion {
    [self callInstanceMethod:GET_TOKEN_SELECTOR args:@[completion]];
}

@end
