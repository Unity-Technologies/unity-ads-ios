#import <Foundation/Foundation.h>
#import "USRVASWebAuthenticationSession.h"

typedef void (^GetSessionsCallback)(NSDictionary<NSString *, USRVASWebAuthenticationSession *> *sessions);
typedef void (^StartSessionCallback)(BOOL didStart);

@interface USRVASWebAuthenticationSessionManager : NSObject
+ (instancetype)sharedInstance;
- (USRVASWebAuthenticationSession *)createSession:(NSURL *)authUrl callbackUrlScheme:(NSString *)callbackUrlSchemeString;
- (void)getSessions:(GetSessionsCallback)callback;
- (void)removeSession:(NSString *)sessionId;
- (void)cancelSession:(NSString *)sessionId;
- (void)startSession:(NSString *)sessionId callback:(StartSessionCallback)callback;
@end
