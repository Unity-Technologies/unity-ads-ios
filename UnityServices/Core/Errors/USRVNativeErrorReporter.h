#import <Foundation/Foundation.h>

@interface USRVNativeErrorReporter : NSObject

+ (void)reportError:(NSString *)errorString;

@end
