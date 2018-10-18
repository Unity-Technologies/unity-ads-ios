

typedef NS_ENUM(NSInteger, UnityServicesCacheEvent) {
    kUnityServicesDownloadStarted,
    kUnityServicesDownloadStopped,
    kUnityServicesDownloadEnd,
    kUnityServicesDownloadProgress,
    kUnityServicesDownloadError
};

NSString *NSStringFromCacheEvent(UnityServicesCacheEvent);
