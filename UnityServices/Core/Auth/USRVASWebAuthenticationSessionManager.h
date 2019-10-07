#import <Foundation/Foundation.h>
#import "USRVASWebAuthenticationSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface USRVASWebAuthenticationSessionManager : NSObject
+ (instancetype)sharedInstance;

- (USRVASWebAuthenticationSession *)createSession:(NSURL *)authUrl callbackUrlScheme:(NSString *)callbackUrlSchemeString;

- (NSDictionary *_Nonnull)getSessions;

- (void)removeSession:(NSString *)sessionId;

- (void)cancelSession:(NSString *)sessionId;

- (BOOL)startSession:(NSString *)sessionId;
@end

NS_ASSUME_NONNULL_END
