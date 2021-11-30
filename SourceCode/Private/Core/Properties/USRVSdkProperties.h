#import "UnityServices.h"
#import "UnityAdsInitializationDelegate.h"
#import "USRVConfiguration.h"

@interface USRVSdkProperties : NSObject

    FOUNDATION_EXPORT NSString *const kUnityServicesCacheDirName;
FOUNDATION_EXPORT NSString *const kUnityServicesLocalCacheFilePrefix;
FOUNDATION_EXPORT NSString *const kUnityServicesLocalStorageFilePrefix;
FOUNDATION_EXPORT NSString *const kUnityServicesWebviewBranchInfoDictionaryKey;
FOUNDATION_EXPORT NSString *const kUnityServicesVersionName;
FOUNDATION_EXPORT int const kUnityServicesVersionCode;
FOUNDATION_EXPORT NSString *const kUnityServicesFlavorDebug;
FOUNDATION_EXPORT NSString *const kUnityServicesFlavorRelease;

typedef NS_ENUM (NSInteger, InitializationState) {
    NOT_INITIALIZED,
    INITIALIZING,
    INITIALIZED_SUCCESSFULLY,
    INITIALIZED_FAILED
};

+ (BOOL)isInitialized;
+ (void)setInitialized: (BOOL)initialized;
+ (BOOL)                                                 isTestMode;
+ (void)setTestMode: (BOOL)testmode;
+ (int)                                                  getVersionCode;
+ (void)setInitializationState: (InitializationState)initializationState;
+ (InitializationState)                                  getCurrentInitializationState;
+ (void)notifyInitializationFailed: (UnityAdsInitializationError)error withErrorMessage: (NSString *)message;
+ (void)                                                 notifyInitializationComplete;
+ (NSString *)                                           getVersionName;
+ (NSString *)                                           getCacheDirectoryName;
+ (NSString *)                                           getCacheFilePrefix;
+ (NSString *)                                           getLocalStorageFilePrefix;
+ (void)setConfigUrl: (NSString *)configUrl;
+ (NSString *)                                           getConfigUrl;
+ (NSString *)getDefaultConfigUrl: (NSString *)flavor;
+ (NSString *)                                           getLocalWebViewFile;
+ (NSString *)                                           getLocalConfigFilepath;
+ (NSString *)                                           getCacheDirectory;
+ (void)setLatestConfiguration: (USRVConfiguration *)configuration;
+ (USRVConfiguration *)                                  getLatestConfiguration;
+ (void)setInitializationTime: (long long)milliseconds;
+ (long long)                                            getInitializationTime;
+ (void)setReinitialized: (BOOL)status;
+ (BOOL)                                                 isReinitialized;
+ (void)setDebugMode: (BOOL)enableDebugMode;
+ (BOOL)                                                 getDebugMode;
+ (void)addInitializationDelegate: (id<UnityAdsInitializationDelegate>)delegate;
+ (NSMutableArray<id<UnityAdsInitializationDelegate> > *)getInitializationDelegates;
+ (void)                                                 resetInitializationDelegates;
+ (BOOL)isChinaLocale: (NSString *)networkISOCode;

@end
