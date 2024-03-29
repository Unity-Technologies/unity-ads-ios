

typedef NS_ENUM (NSInteger, UnityServicesWebViewEventCategory) {
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
    kUnityServicesWebViewEventCategorySKOverlay,
    kUnityServicesWebViewEventCategoryDeviceInfo,
    kUnityServicesWebViewEventCategoryWebPlayer,
    kUnityServicesWebViewEventCategoryBanner,
    kUnityServicesWebViewEventCategoryAR,
    kUnityServicesWebViewEventCategoryPermissions,
    kUnityServicesWebViewEventCategoryNativeError,
    kUnityServicesWebViewEventCategoryWebAuthSession,
    kUnityServicesWebViewEventCategoryLoadApi,
    kUnityServicesWebViewEventCategoryTokenApi,
    kUnityServicesWebViewEventCategorySKAdNetwork
};

NSString * USRVNSStringFromWebViewEventCategory(UnityServicesWebViewEventCategory);
