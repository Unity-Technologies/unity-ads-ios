typedef NS_ENUM(NSInteger, UnityServicesCacheError) {
    kUnityServicesFileIOError,
    kUnityServicesFileNotFound,
    kUnityServicesNoInternet,
    kUnityServicesFileAlreadyCaching,
    kUnityServicesNotCaching,
    kUnityServicesMalformedUrl,
    kUnityServicesNetworkError,
    kUnityServicesInvalidArgument,
    kUnityServicesUnsupportedEncoding,
    kUnityServicesFileStateWrong
};

NSString *USRVNSStringFromCacheError(UnityServicesCacheError error);

@interface USRVApiCache : NSObject
@end
