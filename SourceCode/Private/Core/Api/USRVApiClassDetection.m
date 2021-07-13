#import "USRVApiClassDetection.h"
#import "USRVWebViewApp.h"
#import "USRVClientProperties.h"

@implementation USRVApiClassDetection
+ (void)WebViewExposed_areClassesPresent: (NSArray *)classNames callback: (USRVWebViewCallback *)callback {
    [callback invoke: [USRVClientProperties areClassesPresent: classNames], nil];
}

@end
