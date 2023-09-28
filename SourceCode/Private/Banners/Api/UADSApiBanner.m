#import "UADSApiBanner.h"
#import "USRVWebViewCallback.h"
#import "UADSBannerWebPlayerContainer.h"
#import "UADSWebPlayerSettingsManager.h"
#import "UADSBannerView+UADSBannerWebPlayerContainerDelegate.h"
#import "USRVBannerBridge.h"
#import "UADSBannerRefreshInfo.h"
#import "UADSBannerWebPlayerContainerType.h"
#import "UADSBannerLoadModule.h"
#import "UADSGMAScar.h"
#import "GADBannerViewBridge.h"
#import "GMABannerWebViewEvent.h"
#import "UADSGADBannerWrapper.h"
#import "UIViewController+TopController.h"
#import "UADSTools.h"

@implementation UADSApiBanner

+ (void)WebViewExposed_load: (NSString *)bannerWebPlayerContainerTypeString width: (NSNumber *)width height: (NSNumber *)height bannerAdId: (NSString *)bannerAdId callback: (USRVWebViewCallback *)callback {
    UADSBannerWebPlayerContainerType bannerWebPlayerContainerType = UADSBannerWebPlayerContainerTypeFromNSString(bannerWebPlayerContainerTypeString);

    switch (bannerWebPlayerContainerType) {
        case UADSBannerWebPlayerContainerTypeWebPlayer: {
            NSDictionary *webPlayerSettings = [[UADSWebPlayerSettingsManager sharedInstance] getWebPlayerSettings: bannerAdId];
            NSDictionary *webPlayerEventSettings = [[UADSWebPlayerSettingsManager sharedInstance] getWebPlayerEventSettings: bannerAdId];
            
            UADSBannerView *bannerView = [[UADSBannerLoadModule sharedInstance] bannerViewWithID:bannerAdId];  

            if (bannerView) {
                UADSBannerWebPlayerContainer *bannerWebPlayerContainer = [bannerView getBannerWebPlayerContainer];
                if (bannerWebPlayerContainer) {
                    // if there is already a web player re-use it
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
    }     /* switch */

    [callback invoke: nil];
} /* WebViewExposed_load */

+ (void)WebViewExposed_setRefreshRate: (NSString *)placementId refreshRate: (NSNumber *)refreshRate callback: (USRVWebViewCallback *)callback {
    if (placementId && refreshRate) {
        [[UADSBannerRefreshInfo sharedInstance] setRefreshRateForPlacementId: placementId
                                                                 refreshRate: refreshRate];
    }

    [callback invoke: nil];
}

+ (void)WebViewExposed_loadScar: (NSString *)bannerAd
                    placementId: (NSString *)placementId
                        queryId: (NSString *)queryId
                       adUnitId: (NSString *)adUnitId
                       adString: (NSString *)adString
                          width: (NSNumber *)width
                         height: (NSNumber *)height
                       callback: (USRVWebViewCallback *)callback {
 
    UADSBannerView *bannerView = [[UADSBannerLoadModule sharedInstance] bannerViewWithID:bannerAd];
    if (!bannerView) {
        return;
    }

    CGSize bannerSize = CGSizeMake(width.floatValue, height.floatValue);
    GMAAdMetaData *data = [GMAAdMetaData new];
    data.type = GADQueryInfoAdTypeBanner;
    data.placementID = placementId;
    data.adString = adString;
    data.adUnitID = adUnitId;
    data.queryID = queryId;
    data.bannerAdId = bannerAd;
    data.bannerSize = bannerSize;
    
    UADSGADBannerWrapper *wrapper = [UADSGADBannerWrapper newWithMeta: data
                                                          eventSender: self.eventSender
                                                              gmaScar: UADSGMAScar.sharedInstance];
    
    data.beforeLoad = ^(GADBaseAd *_Nullable ad) {
        wrapper.gadBanner = (GADBannerViewBridge *)ad;
        dispatch_on_main_sync(^{
            [wrapper addToBannerView:bannerView withSize:bannerSize];
        });
    };
    
    id successHandler = ^(GADBaseAd *_Nullable ad) {
        [self.eventSender sendEvent: [GMABannerWebViewEvent newBannerLoadedWithMeta: data]];
    };

    id errorHandler = ^(id<UADSError> _Nonnull error) {
        [self.eventSender sendEvent: [GMABannerWebViewEvent newBannerLoadFailedWithMeta: data]];
        dispatch_on_main_sync(^{
            [wrapper removeFromSuperview]; // remove from UADSBannerView
        });
    };

    UADSLoadAdCompletion *completion = [UADSLoadAdCompletion newWithSuccess: successHandler
                                                                   andError: errorHandler];

    [[UADSGMAScar sharedInstance] loadAdUsingMetaData:data andCompletion:completion];
    [callback invoke: nil];
}

+ (id<UADSWebViewEventSender>)eventSender {
    return [UADSWebViewEventSenderBase new];
}

@end
