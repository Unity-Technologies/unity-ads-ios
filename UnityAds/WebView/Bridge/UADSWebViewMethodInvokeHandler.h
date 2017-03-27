#import <Foundation/Foundation.h>

@interface UADSWebViewMethodInvokeHandler : NSObject

- (void)handleData:(NSData *)jsonData invocationType:(NSString *)invocationType;
- (void)handleInvocation:(NSArray *)invocations;
- (void)handleCallback:(NSDictionary *)callback;

@end
