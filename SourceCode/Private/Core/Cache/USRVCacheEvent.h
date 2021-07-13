

typedef NS_ENUM (NSInteger, UnityServicesCacheEvent) {
    kUnityServicesDownloadStarted,
    kUnityServicesDownloadStopped,
    kUnityServicesDownloadEnd,
    kUnityServicesDownloadProgress,
    kUnityServicesDownloadError
};

NSString * USRVNSStringFromCacheEvent(UnityServicesCacheEvent);
