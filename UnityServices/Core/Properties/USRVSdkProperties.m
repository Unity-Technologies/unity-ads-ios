#import "USRVSdkProperties.h"
#import "USRVDevice.h"

NSString * const kUnityServicesCacheDirName = @"UnityAdsCache";
NSString * const kUnityServicesLocalCacheFilePrefix = @"UnityAdsCache-";
NSString * const kUnityServicesLocalStorageFilePrefix  = @"UnityAdsStorage-";
NSString * const kUnityServicesWebviewBranchInfoDictionaryKey = @"UADSWebviewBranch";
NSString * const kUnityServicesVersionName = @"3.4.8";
NSString * const kUnityServicesFlavorDebug = @"debug";
NSString * const kUnityServicesFlavorRelease = @"release";
NSString * const kChinaIsoAlpha2Code = @"CN";
NSString * const kChinaIsoAlpha3Code = @"CHN";
int const kUnityServicesVersionCode = 3480;

@implementation USRVSdkProperties

static BOOL initialized = false;
static BOOL reinitialized = false;
static long long initializationTime = 0;
static BOOL testMode = false;
static NSString *configUrl = NULL;
static NSString *cacheDirectory = NULL;
static BOOL debug = true;
static BOOL debugMode = NO;
static BOOL usePerPlacementLoad = NO;
static id<UnityServicesDelegate> unityServicesDelegate = NULL;

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
    return kUnityServicesVersionCode;
}

+ (NSString *)getVersionName {
    return kUnityServicesVersionName;
}

+ (NSString *)getCacheDirectoryName {
    return kUnityServicesCacheDirName;
}

+ (NSString *)getCacheFilePrefix {
    return kUnityServicesLocalCacheFilePrefix;
}

+ (NSString *)getLocalStorageFilePrefix {
    return kUnityServicesLocalStorageFilePrefix;
}

+ (void)setConfigUrl:(NSString *)url {
    configUrl = url;
}

+ (NSString *)getConfigUrl {
    if (configUrl == NULL) {
        configUrl = [USRVSdkProperties getDefaultConfigUrl:kUnityServicesFlavorRelease];
    }

    return configUrl;
}

+ (NSString *)getDefaultConfigUrl:(NSString *)flavor {
    NSString *baseURI = @"https://config.unityads.unity3d.com/webview/";
    NSString *versionString = [USRVSdkProperties getVersionName];
    
    // If there is a string object for the key UADSWebviewBranch in the Info.plist of the hosting application,
    // then point the SDK to the webview deployed at that path.
    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:kUnityServicesWebviewBranchInfoDictionaryKey] isKindOfClass:[NSString class]]) {
        versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:kUnityServicesWebviewBranchInfoDictionaryKey];
    }
    
    if ([USRVSdkProperties isChinaLocale:[USRVDevice getNetworkCountryISO]]) {
        baseURI = @"https://config.unityads.unitychina.cn/webview/";
    }

    return [baseURI stringByAppendingFormat:@"%@/%@/config.json", versionString, flavor];
}

+ (NSString *)getLocalWebViewFile {
    return [NSString stringWithFormat:@"%@/UnityAdsWebApp.html", [USRVSdkProperties getCacheDirectory]];
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

+ (void)setDebugMode:(BOOL)enableDebugMode {
    debugMode = enableDebugMode;
    
    if(debugMode) {
        [USRVDeviceLog setLogLevel:kUnityServicesLogLevelDebug];
    } else {
        [USRVDeviceLog setLogLevel:kUnityServicesLogLevelInfo];
    }
}

+ (BOOL)getDebugMode {
    return debugMode;
}

+ (id<UnityServicesDelegate>)getDelegate {
    return unityServicesDelegate;
}

+ (void)setDelegate:(id<UnityServicesDelegate>)delegate {
    unityServicesDelegate = delegate;
}
        
+ (BOOL)isChinaLocale:(NSString *)networkISOCode {
    if ([networkISOCode.uppercaseString isEqualToString:kChinaIsoAlpha2Code] || [networkISOCode.uppercaseString isEqualToString:kChinaIsoAlpha3Code]) {
        return true;
    } else {
        return false;
    }
}

+ (void)setPerPlacementLoadEnabled:(BOOL)perPlacementLoadEnabled {
    usePerPlacementLoad = perPlacementLoadEnabled;
}

+ (BOOL)isPerPlacementLoadEnabled {
    return usePerPlacementLoad;
}

@end
