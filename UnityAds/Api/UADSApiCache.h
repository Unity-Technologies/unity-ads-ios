typedef NS_ENUM(NSInteger, UnityAdsCacheError) {
    kUnityAdsFileIOError,
    kUnityAdsFileNotFound,
    kUnityAdsNoInternet,
    kUnityAdsFileAlreadyCaching,
    kUnityAdsNotCaching,
    kUnityAdsMalformedUrl,
    kUnityAdsNetworkError,
    kUnityAdsInvalidArgument,
    kUnityAdsUnsupportedEncoding
};

NSString *NSStringFromCacheError(UnityAdsCacheError error);

@interface UADSApiCache : NSObject
@end
