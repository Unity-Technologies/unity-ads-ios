typedef NS_ENUM(NSInteger, UnityServicesDeviceError) {
    kUnityServicesCouldntGetSensorInfo,
    kUnityServicesCouldntGetProcessInfo
};

NSString *NSStringFromDeviceError(UnityServicesDeviceError);
