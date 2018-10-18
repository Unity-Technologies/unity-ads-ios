#import <Foundation/Foundation.h>

@interface USRVWebViewMethodInvokeHandler : NSObject

- (void)handleData:(NSData *)jsonData invocationType:(NSString *)invocationType;
- (void)handleInvocation:(NSArray *)invocations;
- (void)handleCallback:(NSDictionary *)callback;

@end
