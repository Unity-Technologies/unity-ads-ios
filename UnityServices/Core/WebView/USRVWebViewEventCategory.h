

typedef NS_ENUM(NSInteger, UnityServicesWebViewEventCategory) {
    kUnityServicesWebViewEventCategoryAdunit,
    kUnityServicesWebViewEventCategoryCache,
    kUnityServicesWebViewEventCategoryConnectivity,
    kUnityServicesWebViewEventCategoryResolve,
    kUnityServicesWebViewEventCategoryStorage,
    kUnityServicesWebViewEventCategoryUrl,
    kUnityServicesWebViewEventCategoryVideoPlayer,
    kUnityServicesWebViewEventCategoryWebViewApp,
    kUnityServicesWebViewEventCategoryNotification,
    kUnityServicesWebViewEventCategoryAppSheet,
    kUnityServicesWebViewEventCategoryDeviceInfo,
    kUnityServicesWebViewEventCategoryWebPlayer,
    kUnityServicesWebViewEventCategoryBanner,
    kUnityServicesWebViewEventCategoryAR,
    kUnityServicesWebViewEventCategoryPermissions
};

NSString *NSStringFromWebViewEventCategory(UnityServicesWebViewEventCategory);
