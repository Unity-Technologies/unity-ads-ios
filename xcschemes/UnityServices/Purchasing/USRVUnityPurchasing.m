#import "USRVUnityPurchasing.h"
#import "UPURClientProperties.h"

@implementation USRVUnityPurchasing

+(void)setDelegate:(id<USRVUnityPurchasingDelegate>)delegate {
    [UPURClientProperties setDelegate:delegate];
}
+(id<USRVUnityPurchasingDelegate>)getDelegate {
    return [UPURClientProperties getDelegate];
}

@end
