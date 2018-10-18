

typedef NS_ENUM(NSInteger, UnityServicesStorageError) {
    kUnityServicesCouldntSetValue,
    kUnityServicesCouldntGetValue,
    kUnityServicesCouldntWriteStorageToCache,
    kUnityServicesCouldntClearStorage,
    kUnityServicesCouldntGetStorage,
    kUnityServicesCouldntDeleteValue
};

NSString *NSStringFromStorageError(UnityServicesStorageError);
