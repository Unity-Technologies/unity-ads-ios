#import "USRVApiUrlScheme.h"
#import "USRVWebViewCallback.h"
#import <UIKit/UIKit.h>

@implementation USRVApiUrlScheme

+ (void)WebViewExposed_open:(NSString *)url callback:(USRVWebViewCallback *)callback {
    [USRVApiUrlScheme openUrlScheme:url];
    [callback invoke:nil];
}

+ (void)openUrlScheme:(NSString *)url {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end
