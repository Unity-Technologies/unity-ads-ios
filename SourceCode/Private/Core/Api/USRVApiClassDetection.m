#import "USRVApiClassDetection.h"
#import "USRVWebViewApp.h"
#import "USRVMadeWithUnityDetector.h"

@implementation USRVApiClassDetection

+ (void)WebViewExposed_isMadeWithUnity: (USRVWebViewCallback *)callback {
    [callback invoke: [NSNumber numberWithBool: [USRVMadeWithUnityDetector isMadeWithUnity]], nil];
}

@end
