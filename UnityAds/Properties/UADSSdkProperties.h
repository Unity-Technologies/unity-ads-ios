

@interface UADSSdkProperties : NSObject

FOUNDATION_EXPORT NSString * const kUnityAdsCacheDirName;
FOUNDATION_EXPORT NSString * const kUnityAdsLocalCacheFilePrefix;
FOUNDATION_EXPORT NSString * const kUnityAdsLocalStorageFilePrefix;
FOUNDATION_EXPORT NSString * const kUnityAdsWebviewBranchInfoDictionaryKey;
FOUNDATION_EXPORT NSString * const kUnityAdsVersionName;
FOUNDATION_EXPORT int const kUnityAdsVersionCode;
FOUNDATION_EXPORT NSString * const kUnityAdsFlavorDebug;
FOUNDATION_EXPORT NSString * const kUnityAdsFlavorRelease;

+ (BOOL)isInitialized;
+ (void)setInitialized:(BOOL)initialized;
+ (BOOL)isTestMode;
+ (void)setTestMode:(BOOL)testmode;
+ (int)getVersionCode;
+ (NSString *)getVersionName;
+ (NSString *)getCacheDirectoryName;
+ (NSString *)getCacheFilePrefix;
+ (NSString *)getLocalStorageFilePrefix;
+ (void)setConfigUrl:(NSString *)configUrl;
+ (NSString *)getConfigUrl;
+ (NSString *)getDefaultConfigUrl:(NSString *)flavor;
+ (NSString *)getLocalWebViewFile;
+ (NSString *)getCacheDirectory;
+ (void)setShowTimeout:(int)timeout;
+ (int)getShowTimeout;
@end
