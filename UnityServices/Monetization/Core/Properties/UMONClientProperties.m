#import "UnityMonetizationDelegate.h"
#import "UMONClientProperties.h"

@implementation UMONClientProperties
static BOOL _enabled;
static id <UnityMonetizationDelegate> _listener;

+(id <UnityMonetizationDelegate>)getDelegate {
    return _listener;
}

+(void)setDelegate:(id <UnityMonetizationDelegate>)listener {
    _listener = listener;
}
+(BOOL)monetizationEnabled {
    return _enabled;
}
+(void)setMonetizationEnabled:(BOOL)isEnabled {
    _enabled = isEnabled;
}

@end

