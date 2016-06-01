#import "UADSWebViewCallback.h"

@interface UADSWebViewBridge : NSObject

+ (void)handleInvocation:(NSInvocation *)invocation;
+ (void)handleCallback:(NSString *)callbackId callbackStatus:(NSString *)callbackStatus params:(NSArray *)params;

@end