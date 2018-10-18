#import "USRVUnityPurchasingDelegate.h"

@interface UPURClientProperties : NSObject
+(void)setDelegate:(id<USRVUnityPurchasingDelegate>)delegate;
+(id<USRVUnityPurchasingDelegate>)getDelegate;
@end
