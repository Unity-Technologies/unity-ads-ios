#import "USRVInitializationDelegate.h"

@interface UADSLoadModule : NSObject <USRVInitializationDelegate>
+(instancetype)sharedInstance;

-(void)load:(NSString *)placementId;

@end
