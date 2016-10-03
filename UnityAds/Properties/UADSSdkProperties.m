#import "UADSSdkProperties.h"

NSString * const kUnityAdsCacheDirName = @"UnityAdsCache";
NSString * const kUnityAdsLocalCacheFilePrefix = @"UnityAdsCache-";
NSString * const kUnityAdsLocalStorageFilePrefix  = @"UnityAdsStorage-";
NSString * const kUnityAdsVersionName = @"2.0.5";
NSString * const kUnityAdsFlavorDebug = @"debug";
NSString * const kUnityAdsFlavorRelease = @"release";
int const kUnityAdsVersionCode = 2005;

@implementation UADSSdkProperties

static BOOL initialized = false;
static BOOL testMode = false;
static int showTimeout = 5000;
static NSString *configUrl = NULL;
static NSString *cacheDirectory = NULL;
static BOOL debug = true;

+ (BOOL)isInitialized {
    return initialized;
}

+ (BOOL)isDebug {
    return debug;
}

+ (void)setInitialized:(BOOL)isInitialized {
    initialized = isInitialized;
}

+ (BOOL)isTestMode {
    return testMode;
}

+ (void)setTestMode:(BOOL)isTestMode {
    testMode = isTestMode;
}

+ (int)getVersionCode {
    return kUnityAdsVersionCode;
}

+ (NSString *)getVersionName {
    return kUnityAdsVersionName;
}

+ (NSString *)getCacheDirectoryName {
    return kUnityAdsCacheDirName;
}

+ (NSString *)getCacheFilePrefix {
    return kUnityAdsLocalCacheFilePrefix;
}

+ (NSString *)getLocalStorageFilePrefix {
    return kUnityAdsLocalStorageFilePrefix;
}

+ (void)setConfigUrl:(NSString *)url {
    configUrl = url;
}

+ (NSString *)getConfigUrl {
    if (configUrl == NULL) {
        configUrl = [UADSSdkProperties getDefaultConfigUrl:kUnityAdsFlavorRelease];
    }

    return configUrl;
}

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)

+ (NSString *)getDefaultConfigUrl:(NSString *)flavor {
    NSString *defaultConfigUrl = @"https://config.unityads.unity3d.com/webview/";
    
#ifdef DEBUG
#ifdef UADSWEBVIEW_BRANCH
    NSString *versionString = @STRINGIZE2(UADSWEBVIEW_BRANCH);
#else
    NSString *versionString = @"master";
#endif
#else
#ifdef UADSWEBVIEW_BRANCH
    NSString *versionString = @STRINGIZE2(UADSWEBVIEW_BRANCH);
#else
    NSString *versionString = [UADSSdkProperties getVersionName];
#endif
#endif

    defaultConfigUrl = [defaultConfigUrl stringByAppendingFormat:@"%@/%@/config.json", versionString, flavor];
    
    return defaultConfigUrl;
}

+ (NSString *)getLocalWebViewFile {
    return [NSString stringWithFormat:@"%@/UnityAdsWebApp.html", [UADSSdkProperties getCacheDirectory]];
}

+ (NSString *)getCacheDirectory {
    if (cacheDirectory == NULL) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        
        BOOL cacheLocationIsDirectory = YES;
        if (paths.count != 0) {
            [[NSFileManager defaultManager] fileExistsAtPath:[paths firstObject] isDirectory:&cacheLocationIsDirectory];
        }
        
        if (cacheLocationIsDirectory) {
            cacheDirectory = [paths firstObject];
        } else {
            cacheDirectory = NSTemporaryDirectory();
        }
        
    }

    return cacheDirectory;
}

+ (void)setShowTimeout:(int)timeout {
    showTimeout = timeout;
}

+ (int)getShowTimeout {
    return showTimeout;
}

@end
