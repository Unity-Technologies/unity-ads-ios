#import "UADSTokenStorageEventHandler.h"
#import "USRVWebViewApp.h"
#import "USRVWebViewEventCategory.h"
#import "UADSTokenStorageEvent.h"

@implementation UADSTokenStorageEventHandler

- (void)sendQueueEmpty {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[USRVWebViewApp getCurrentApp] sendEvent: UADSNSStringFromTokenStorageEvent(kUnityAdsTokenStorageQueueEmpty)
                                         category: USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryTokenApi)
                                           params: @[]];
    });
}

- (void)sendTokenAccessIndex: (NSNumber *)index {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[USRVWebViewApp getCurrentApp] sendEvent: UADSNSStringFromTokenStorageEvent(kUnityAdsTokenStorageAccessToken)
                                         category: USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryTokenApi)
                                           params: @[index]];
    });
}

@end
