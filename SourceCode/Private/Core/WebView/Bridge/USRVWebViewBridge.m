#import "USRVWebViewBridge.h"
#import "USRVWebViewApp.h"
#import "USRVNativeCallback.h"


@implementation USRVWebViewBridge

+ (void)handleInvocation: (NSInvocation *)invocation {
    [invocation invoke];
}

+ (void)handleCallback: (NSString *)callbackId callbackStatus: (NSString *)callbackStatus params: (NSArray *)params {
    USRVNativeCallback *callback = [[USRVWebViewApp getCurrentApp] getCallbackWithId: callbackId];

    if (callback) {
        [callback invokeWithStatus: callbackStatus
                            params: params];
    } else {
        NSException *exception = [NSException
                                  exceptionWithName: @"NullPointerException"
                                             reason: [NSString stringWithFormat: @"NativeCallback %@ was NULL", callbackId]
                                           userInfo: nil];
        @throw exception;
    }
}

@end
