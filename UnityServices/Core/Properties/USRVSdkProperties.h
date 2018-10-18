#import "UnityServices.h"

@interface USRVSdkProperties : NSObject

FOUNDATION_EXPORT NSString * const kUnityServicesCacheDirName;
FOUNDATION_EXPORT NSString * const kUnityServicesLocalCacheFilePrefix;
FOUNDATION_EXPORT NSString * const kUnityServicesLocalStorageFilePrefix;
FOUNDATION_EXPORT NSString * const kUnityServicesWebviewBranchInfoDictionaryKey;
FOUNDATION_EXPORT NSString * const kUnityServicesVersionName;
FOUNDATION_EXPORT int const kUnityServicesVersionCode;
FOUNDATION_EXPORT NSString * const kUnityServicesFlavorDebug;
FOUNDATION_EXPORT NSString * const kUnityServicesFlavorRelease;

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
+ (void)setInitializationTime:(long long)milliseconds;
+ (long long)getInitializationTime;
+ (void)setReinitialized:(BOOL)status;
+ (BOOL)isReinitialized;
+ (void)setDebugMode:(BOOL)enableDebugMode;
+ (BOOL)getDebugMode;
+ (id<UnityServicesDelegate>)getDelegate;
+ (void)setDelegate:(id<UnityServicesDelegate>)delegate;

@end
