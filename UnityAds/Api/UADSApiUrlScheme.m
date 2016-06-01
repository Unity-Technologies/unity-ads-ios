#import "UADSApiUrlScheme.h"
#import "UADSWebViewCallback.h"
#import <UIKit/UIKit.h>

@implementation UADSApiUrlScheme

+ (void)WebViewExposed_open:(NSString *)url callback:(UADSWebViewCallback *)callback {
    [UADSApiUrlScheme openUrlScheme:url];
    [callback invoke:nil];
}

+ (void)openUrlScheme:(NSString *)url {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end