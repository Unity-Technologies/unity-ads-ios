

typedef NS_ENUM(NSInteger, UnityAdsWebViewEventCategory) {
    kUnityAdsWebViewEventCategoryAdunit,
    kUnityAdsWebViewEventCategoryCache,
    kUnityAdsWebViewEventCategoryConnectivity,
    kUnityAdsWebViewEventCategoryResolve,
    kUnityAdsWebViewEventCategoryStorage,
    kUnityAdsWebViewEventCategoryUrl,
    kUnityAdsWebViewEventCategoryVideoPlayer,
    kUnityAdsWebViewEventCategoryWebViewApp,
    kUnityAdsWebViewEventCategoryNotification,
    kUnityAdsWebViewEventCategoryAppSheet,
    kUnityAdsWebViewEventCategoryDeviceInfo
};

NSString *NSStringFromWebViewEventCategory(UnityAdsWebViewEventCategory);
