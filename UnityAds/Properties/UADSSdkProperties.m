#import "UADSSdkProperties.h"

NSString * const kUnityAdsCacheDirName = @"UnityAdsCache";
NSString * const kUnityAdsLocalCacheFilePrefix = @"UnityAdsCache-";
NSString * const kUnityAdsLocalStorageFilePrefix  = @"UnityAdsStorage-";
NSString * const kUnityAdsWebviewBranchInfoDictionaryKey = @"UADSWebviewBranch";
NSString * const kUnityAdsVersionName = @"2.1.0";
NSString * const kUnityAdsFlavorDebug = @"debug";
NSString * const kUnityAdsFlavorRelease = @"release";
int const kUnityAdsVersionCode = 2100;

@implementation UADSSdkProperties

static BOOL initialized = false;
static BOOL reinitialized = false;
static long long initializationTime = 0;
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

+ (NSString *)getDefaultConfigUrl:(NSString *)flavor {
    NSString *defaultConfigUrl = @"https://config.unityads.unity3d.com/webview/";
    NSString *versionString = [UADSSdkProperties getVersionName];
    
    // If there is a string object for the key UADSWebviewBranch in the Info.plist of the hosting application,
    // then point the SDK to the webview deployed at that path.
    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:kUnityAdsWebviewBranchInfoDictionaryKey] isKindOfClass:[NSString class]]) {
        versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:kUnityAdsWebviewBranchInfoDictionaryKey];
    }

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

+ (void)setInitializationTime:(long long)milliseconds {
    initializationTime = milliseconds;
}

+ (long long)getInitializationTime {
    return initializationTime;
}

+ (void)setReinitialized:(BOOL)status {
    reinitialized = status;
}

+ (BOOL)isReinitialized {
    return reinitialized;
}
@end
