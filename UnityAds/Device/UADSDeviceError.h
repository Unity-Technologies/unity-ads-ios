typedef NS_ENUM(NSInteger, UnityAdsDeviceError) {
    kUnityAdsCouldntGetSensorInfo,
    kUnityAdsCouldntGetProcessInfo
};

NSString *NSStringFromDeviceError(UnityAdsDeviceError);
