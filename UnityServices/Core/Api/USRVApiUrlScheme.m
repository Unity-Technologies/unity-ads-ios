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

+ (void)WebViewExposed_canOpenUrlScheme:(NSString *)url callback:(USRVWebViewCallback *)callback {
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:^(BOOL finished) {
            [callback invoke:[NSNumber numberWithBool:finished], nil];
        }];
    } else {
        [callback invoke:[NSNumber numberWithBool:NO], nil];
    }
}

@end
