#import "USRVWebViewCallback.h"

@interface USRVWebViewBridge : NSObject

+ (void)handleInvocation:(NSInvocation *)invocation;
+ (void)handleCallback:(NSString *)callbackId callbackStatus:(NSString *)callbackStatus params:(NSArray *)params;

@end
