#import <Foundation/Foundation.h>

@protocol USRVInitializationDelegate <NSObject>

-(void)sdkDidInitialize;

-(void)sdkInitializeFailed:(NSError *)error;

@end
