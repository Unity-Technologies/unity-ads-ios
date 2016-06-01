

typedef NS_ENUM(NSInteger, UnityAdsCacheEvent) {
    kUnityAdsDownloadStarted,
    kUnityAdsDownloadStopped,
    kUnityAdsDownloadEnd,
    kUnityAdsDownloadProgress,
    kUnityAdsDownloadError
};

NSString *NSStringFromCacheEvent(UnityAdsCacheEvent);
