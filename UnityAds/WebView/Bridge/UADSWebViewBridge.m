#import "UnityAds.h"
#import "UADSWebViewBridge.h"
#import "UADSNativeCallback.h"
#import "UADSWebViewApp.h"


@implementation UADSWebViewBridge

+ (void)handleInvocation:(NSInvocation *)invocation {
    [invocation invoke];
}

+ (void)handleCallback:(NSString *)callbackId callbackStatus:(NSString *)callbackStatus params:(NSArray *)params {
    UADSNativeCallback *callback = [[UADSWebViewApp getCurrentApp] getCallbackWithId:callbackId];

    if (callback) {
        [callback invokeWithStatus:callbackStatus params:params];
    }
    else {
        NSException* exception = [NSException
                                  exceptionWithName:@"NullPointerException"
                                  reason:@"NativeCallback was NULL"
                                  userInfo:nil];
        @throw exception;
    }
}

@end