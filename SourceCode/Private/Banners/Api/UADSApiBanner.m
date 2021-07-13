#import "UADSApiBanner.h"
#import "USRVWebViewCallback.h"
#import "UADSBannerWebPlayerContainer.h"
#import "UADSWebPlayerSettingsManager.h"
#import "UADSBannerViewManager.h"
#import "UADSBannerView+UADSBannerWebPlayerContainerDelegate.h"
#import "USRVBannerBridge.h"
#import "UADSBannerRefreshInfo.h"
#import "UADSBannerWebPlayerContainerType.h"

@implementation UADSApiBanner

+ (void)WebViewExposed_load: (NSString *)bannerWebPlayerContainerTypeString width: (NSNumber *)width height: (NSNumber *)height bannerAdId: (NSString *)bannerAdId callback: (USRVWebViewCallback *)callback {
    UADSBannerWebPlayerContainerType bannerWebPlayerContainerType = UADSBannerWebPlayerContainerTypeFromNSString(bannerWebPlayerContainerTypeString);

    switch (bannerWebPlayerContainerType) {
        case UADSBannerWebPlayerContainerTypeWebPlayer: {
            NSDictionary *webPlayerSettings = [[UADSWebPlayerSettingsManager sharedInstance] getWebPlayerSettings: bannerAdId];
            NSDictionary *webPlayerEventSettings = [[UADSWebPlayerSettingsManager sharedInstance] getWebPlayerEventSettings: bannerAdId];
            UADSBannerView *bannerView = [[UADSBannerViewManager sharedInstance] getBannerViewWithBannerAdId: bannerAdId];

            if (bannerView) {
                if ([bannerView getBannerWebPlayerContainer]) {
                    // if there is already a web player re-use it
                    UADSBannerWebPlayerContainer *bannerWebPlayerContainer = [bannerView getBannerWebPlayerContainer];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // update banner view settings
                        [bannerWebPlayerContainer.webPlayer setWebPlayerSettings: webPlayerSettings];
                        [bannerWebPlayerContainer.webPlayer setEventSettings: webPlayerEventSettings];

                        [USRVBannerBridge bannerDidLoadedWithBannerId: bannerAdId];
                    });
                } else {
                    // if there is not a web player create one
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // banner view needs to be init on main thread
                        float widthAsFloat = [width floatValue];
                        float heightAsFloat = [height floatValue];
                        CGSize bannerSize = CGSizeMake(widthAsFloat, heightAsFloat);
                        UADSBannerWebPlayerContainer *bannerWebPlayerContainer = [[UADSBannerWebPlayerContainer alloc] initWithBannerAdId: bannerAdId
                                                                                                                        webPlayerSettings: webPlayerSettings
                                                                                                                   webPlayerEventSettings: webPlayerEventSettings
                                                                                                                                     size: bannerSize];

                        [bannerView setBannerWebPlayerContainer: bannerWebPlayerContainer];

                        [USRVBannerBridge bannerDidLoadedWithBannerId: bannerAdId];
                    });
                }
            }

            break;
        }

        case UADSBannerWebPlayerContainerTypeUnknown:
            // do nothing
            break;
    } /* switch */

    [callback invoke: nil];
} /* WebViewExposed_load */

+ (void)WebViewExposed_setRefreshRate: (NSString *)placementId refreshRate: (NSNumber *)refreshRate callback: (USRVWebViewCallback *)callback {
    if (placementId && refreshRate) {
        [[UADSBannerRefreshInfo sharedInstance] setRefreshRateForPlacementId: placementId
                                                                 refreshRate: refreshRate];
    }

    [callback invoke: nil];
}

@end
