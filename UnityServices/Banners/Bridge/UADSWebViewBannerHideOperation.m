#import "UADSWebViewBannerHideOperation.h"
#import "UADSProperties.h"

@implementation UADSWebViewBannerHideOperation

-(instancetype)init {
    NSArray *params = @[];
    self = [super initWithMethod:@"hideBanner" webViewClass:@"webview" parameters:params waitTime:[UADSProperties getShowTimeout] / 1000];
    return self;
}

-(void)main {
    [super main];

    if (self.success) {
        USRVLogDebug(@"HIDE BANNER SUCCESS");
    }
}

+(void)callback:(NSArray *)params {
    if ([[params objectAtIndex:0] isEqualToString:@"OK"]) {
        [super callback:params];
    }
}

@end
