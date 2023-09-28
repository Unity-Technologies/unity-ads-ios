#import "USRVSdkProperties.h"
#import "USRVDevice.h"
#import "UnityAdsInitializationDelegate.h"
#import "UADSBaseURLBuilder.h"
#import "USRVClientProperties.h"
#import "UADSConfigurationEndpointProvider.h"
#import "UADSServiceProviderContainer.h"

NSString *const kUnityServicesCacheDirName = @"UnityAdsCache";
NSString *const kUnityServicesLocalCacheFilePrefix = @"UnityAdsCache-";
NSString *const kUnityServicesLocalStorageFilePrefix = @"UnityAdsStorage-";
NSString *const kUnityServicesWebviewBranchInfoDictionaryKey = @"UADSWebviewBranch";
NSString *const kUnityServicesWebviewConfigInfoDictionaryKey = @"UADSWebviewConfig";
NSString *const kUnityServicesVersionName = @"4.9.0";
NSString *const kUnityServicesFlavorDebug = @"debug";
NSString *const kUnityServicesFlavorRelease = @"release";
NSString *const kChinaIsoAlpha2Code = @"CN";
NSString *const kChinaIsoAlpha3Code = @"CHN";
int const kUnityServicesVersionCode = 4900;

@implementation USRVSdkProperties

static BOOL initialized = false;
static BOOL reinitialized = false;
static long long initializationTime = 0;
static BOOL testMode = false;
static NSString *configUrl = NULL;
static NSString *cacheDirectory = NULL;
static BOOL debug = true;
static BOOL debugMode = NO;
static NSMutableOrderedSet<id<UnityAdsInitializationDelegate> > *initializationDelegates;
static USRVConfiguration *latestConfiguration;
static InitializationState currentInitializeState = NOT_INITIALIZED;
static dispatch_queue_t queue;

+ (BOOL)isInitialized {
    return initialized;
}

+ (BOOL)isDebug {
    return debug;
}

+ (void)setInitialized: (BOOL)isInitialized {
    initialized = isInitialized;
}

+ (BOOL)isTestMode {
    return testMode;
}

+ (void)setTestMode: (BOOL)isTestMode {
    testMode = isTestMode;
}

+ (int)getVersionCode {
    return kUnityServicesVersionCode;
}

+ (void)setInitializationState: (InitializationState)initializationState {
    dispatch_sync(queue, ^{
        currentInitializeState = initializationState;
    });
}

+ (InitializationState)getCurrentInitializationState {
    UADSServiceProvider *provider = UADSServiceProviderContainer.sharedInstance.serviceProvider;
    if ([provider.configurationStorage.currentSessionExperiments isSwiftInitFlowEnabled]) {
        return [provider.objBridge currentState];
    }
    return currentInitializeState;
}

+ (void)notifyInitializationFailed: (UnityAdsInitializationError)error withErrorMessage: (NSString *)message {
    [self setInitializationState: INITIALIZED_FAILED];

    @synchronized (initializationDelegates) {
        for (id <UnityAdsInitializationDelegate> initializationDelegate in initializationDelegates) {
            [initializationDelegate initializationFailed: error
                                             withMessage: message];
        }

        [self resetInitializationDelegates];
    }
}

+ (void)notifyInitializationComplete {
    [self setInitializationState: INITIALIZED_SUCCESSFULLY];

    @synchronized (initializationDelegates) {
        for (id <UnityAdsInitializationDelegate> initializationDelegate in initializationDelegates) {
            [initializationDelegate initializationComplete];
        }

        [self resetInitializationDelegates];
    }
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

+ (void)setConfigUrl: (NSString *)url {
    configUrl = url;
}

+ (NSString *)getConfigUrl {
    if (configUrl == NULL) {
        configUrl = [USRVSdkProperties getDefaultConfigUrl: kUnityServicesFlavorRelease];
    }

    return configUrl;
}

+ (NSString *)getDefaultConfigUrl: (NSString *)flavor {
    UADSConfigurationEndpointProvider *endpointProvider = UADSConfigurationEndpointProvider.defaultProvider;
    NSString *baseURI = [@"https://" stringByAppendingFormat: @"%@/webview/", endpointProvider.hostname];
    NSString *versionString = [USRVSdkProperties getVersionName];

    // If there is a string object for the key UADSWebviewBranch in the Info.plist of the hosting application,
    // then point the SDK to the webview deployed at that path.
    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey: kUnityServicesWebviewConfigInfoDictionaryKey] isKindOfClass: [NSString class]]) {
        return [[NSBundle mainBundle] objectForInfoDictionaryKey: kUnityServicesWebviewConfigInfoDictionaryKey];
    }

    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey: kUnityServicesWebviewBranchInfoDictionaryKey] isKindOfClass: [NSString class]]) {
        versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey: kUnityServicesWebviewBranchInfoDictionaryKey];
    }

    return [baseURI stringByAppendingFormat: @"%@/%@/config.json?gameId=%@", versionString, flavor, [USRVClientProperties getGameId]];
}

+ (NSString *)getLocalWebViewFile {
    return [NSString stringWithFormat: @"%@/UnityAdsWebApp.html", [USRVSdkProperties getCacheDirectory]];
}

+ (NSString *)getLocalConfigFilepath {
    return [NSString stringWithFormat: @"%@/UnityAdsWebViewConfiguration.json", [USRVSdkProperties getCacheDirectory]];
}

+ (NSString *)getCacheDirectory {
    if (cacheDirectory == NULL) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);

        BOOL cacheLocationIsDirectory = YES;

        if (paths.count != 0) {
            [[NSFileManager defaultManager] fileExistsAtPath: [paths firstObject]
                                                 isDirectory: &cacheLocationIsDirectory];
        }

        if (cacheLocationIsDirectory) {
            cacheDirectory = [paths firstObject];
        } else {
            cacheDirectory = NSTemporaryDirectory();
        }
    }

    return cacheDirectory;
}

+ (void)setLatestConfiguration: (USRVConfiguration *)configuration {
    latestConfiguration = configuration;
}

+ (USRVConfiguration *)getLatestConfiguration {
    return latestConfiguration;
}

+ (void)setInitializationTime: (long long)milliseconds {
    initializationTime = milliseconds;
}

+ (long long)getInitializationTime {
    return initializationTime;
}

+ (void)setReinitialized: (BOOL)status {
    reinitialized = status;
}

+ (BOOL)isReinitialized {
    return reinitialized;
}

+ (void)setDebugMode: (BOOL)enableDebugMode {
    debugMode = enableDebugMode;

    if (debugMode) {
        [USRVDeviceLog setLogLevel: kUnityServicesLogLevelDebug];
    } else {
        [USRVDeviceLog setLogLevel: kUnityServicesLogLevelInfo];
    }
}

+ (BOOL)getDebugMode {
    return debugMode;
}

+ (void)addInitializationDelegate: (id<UnityAdsInitializationDelegate>)delegate {
    if (delegate == nil) {
        return;
    }

    @synchronized (initializationDelegates) {
        [initializationDelegates addObject: delegate];
    }
}

+ (NSArray<id<UnityAdsInitializationDelegate> > *)getInitializationDelegates {
    if (initializationDelegates == nil) {
        return [[NSArray alloc] init];
    }

    @synchronized (initializationDelegates) {
        NSArray *delegates = [NSArray arrayWithArray: [initializationDelegates array]];
        return delegates;
    }
}

+ (void)resetInitializationDelegates {
    if (initializationDelegates == nil) {
        return;
    }

    @synchronized (initializationDelegates) {
        [initializationDelegates removeAllObjects];
    }
}

+ (BOOL)isChinaLocale: (NSString *)networkISOCode {
    if ([networkISOCode.uppercaseString isEqualToString: kChinaIsoAlpha2Code] || [networkISOCode.uppercaseString isEqualToString: kChinaIsoAlpha3Code]) {
        return true;
    } else {
        return false;
    }
}

+ (void)initialize {
    if (self == [USRVSdkProperties class]) {
        initializationDelegates = [[NSMutableOrderedSet alloc] init];
        queue = dispatch_queue_create("com.unity3d.ads.initialization.state.queue", nil);
        dispatch_set_target_queue(queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    }
}

@end