

typedef NS_ENUM(NSInteger, UnityAdsStorageError) {
    kUnityAdsCouldntSetValue,
    kUnityAdsCouldntGetValue,
    kUnityAdsCouldntWriteStorageToCache,
    kUnityAdsCouldntClearStorage,
    kUnityAdsCouldntGetStorage,
    kUnityAdsCouldntDeleteValue
};

NSString *NSStringFromStorageError(UnityAdsStorageError);
