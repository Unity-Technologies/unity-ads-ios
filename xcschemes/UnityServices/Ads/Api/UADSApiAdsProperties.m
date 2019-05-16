#import "UADSApiAdsProperties.h"
#import "USRVWebViewCallback.h"
#import "UADSProperties.h"

@implementation UADSApiAdsProperties

+ (void)WebViewExposed_setShowTimeout:(NSNumber *)timeout callback:(USRVWebViewCallback *)callback {
    [UADSProperties setShowTimeout:[timeout intValue]];
    [callback invoke:nil];
}

@end
