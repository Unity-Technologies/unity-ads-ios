#import "USRVApiSKAdNetwork.h"
#import "USRVWebViewCallback.h"
#import "USRVSKAdNetworkProxy.h"

@implementation USRVApiSKAdNetwork


+(void)WebViewExposed_available:(USRVWebViewCallback *)callback {
    BOOL available = [[USRVSKAdNetworkProxy sharedInstance] available];
    [callback invoke:[NSNumber numberWithBool:available], nil];
}

+(void)WebViewExposed_updateConversionValue:(NSInteger)conversionValue callback:(USRVWebViewCallback *)callback {
    [[USRVSKAdNetworkProxy sharedInstance] updateConversionValue:conversionValue];
    [callback invoke:nil];
}

+(void)WebViewExposed_registerAppForAdNetworkAttribution:(USRVWebViewCallback *)callback {
    [[USRVSKAdNetworkProxy sharedInstance] registerAppForAdNetworkAttribution];
    [callback invoke:nil];
}

@end
