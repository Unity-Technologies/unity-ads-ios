#import "UADSCommonNetworkProxy.h"

static NSString *const kSendRequestMethodName = @"sendRequestUsing:success:failure:";

static NSString *const kSendWebViewDownloadMethodName = @"downloadWebViewSyncWithCompletion:error:";
@implementation UADSCommonNetworkProxy

+ (NSString *)className {
    return @"UnityAds.NetworkLayerObjCBridge";
}

- (void)sendRequestUsing: (NSDictionary *)dictionary
       successCompletion: (UADSNetworkSuccessCompletion)success
      andErrorCompletion: (UADSNetworkErrorCompletion)errorCompletion {
    id successCompletion = ^(id obj) {
        success(obj);
    };

    [self callInstanceMethod: kSendRequestMethodName
                        args: @[dictionary, successCompletion, errorCompletion]];
}

- (void)downloadWebView: (UADSDownloadSuccessCompletion)success
               andError: (UADSNetworkErrorCompletion)errorCompletion {
    [self callInstanceMethod: kSendWebViewDownloadMethodName
                        args: @[success, errorCompletion]];
}

@end
