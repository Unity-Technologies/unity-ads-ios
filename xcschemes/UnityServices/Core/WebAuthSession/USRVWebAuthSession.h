#import <Foundation/Foundation.h>

@interface USRVWebAuthSession : NSObject

+ (void)sendSessionResult:(NSString *)sessionId callbackUrl:(NSURL *)callbackUrl error:(NSError *)error;
+ (void)sendStartSessionResult:(NSString *)sessionId didStart:(BOOL)didStart;

@end
