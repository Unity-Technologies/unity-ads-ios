#import "UPURClientProperties.h"

@implementation UPURClientProperties
static id<USRVUnityPurchasingDelegate> _adapter;
+(void)setDelegate:(id<USRVUnityPurchasingDelegate>)delegate {
    _adapter = delegate;
}
+(id <USRVUnityPurchasingDelegate>)getDelegate {
    return _adapter;
}
@end
