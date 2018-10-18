#import "UnityMonetizationDelegate.h"

@interface UMONClientProperties : NSObject
+(id <UnityMonetizationDelegate>)getDelegate;
+(void)setDelegate:(id <UnityMonetizationDelegate>)listener;
+(BOOL)monetizationEnabled;
+(void)setMonetizationEnabled:(BOOL)isEnabled;
@end

