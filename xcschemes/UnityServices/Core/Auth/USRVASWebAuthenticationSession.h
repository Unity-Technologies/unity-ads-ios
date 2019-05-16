#import "USRVWebViewApp.h"

@interface USRVASWebAuthenticationSession : NSObject

- (NSString *)getSessionId;
- (instancetype)initWithAuthUrl:(NSURL *)authSessionUrl callbackUrlScheme:(NSString *)callbackUrlScheme;
- (void)cancel;
- (BOOL)start;

@end
