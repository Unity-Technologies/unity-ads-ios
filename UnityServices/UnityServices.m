#import "UnityServices.h"
#import "USRVSdkProperties.h"
#import "USRVEnvironmentProperties.h"
#import "USRVClientProperties.h"
#import "USRVInitialize.h"

static BOOL _initializing = NO;

@implementation UnityServices

+ (void)initialize:(NSString *)gameId
          delegate:(nullable id<UnityServicesDelegate>)delegate {
    
}

+ (void)initialize:(NSString *)gameId
          delegate:(nullable id<UnityServicesDelegate>)delegate
          testMode:(BOOL)testMode {
    
    BOOL didError = NO;
    UnityServicesError unityServicesError = 0;
    
    // Already initialized or currently initializing, error and bail
    if ([USRVSdkProperties isInitialized] || _initializing) {
        if ([USRVClientProperties getGameId] && ![[USRVClientProperties getGameId] isEqualToString:gameId]) {
            USRVLogWarning(@"You are trying to re-initialize with different gameId!");
        }
        
        didError = YES;
        unityServicesError = kUnityServicesErrorInitSanityCheckFail;
    }
    // Bad game id or nil delegate
    if (!gameId || [gameId length] == 0) {
        USRVLogError(@"Unity ads init: invalid argument, halting init");
        didError = YES;
        unityServicesError = kUnityServicesErrorInvalidArgument;
    }
    
    if (didError) {
        if (delegate != nil && [delegate respondsToSelector:@selector(unityServicesDidError:withMessage:)]) {
            [delegate unityServicesDidError:unityServicesError withMessage:@""];
        }
        
        return;
    }
    
    [USRVSdkProperties setInitializationTime:[[NSDate date] timeIntervalSince1970] * 1000];
    
    _initializing = YES;
    @synchronized (self) {
        if(testMode) {
            USRVLogInfo(@"Initializing Unity Ads %@ (%d) with game id %@ in test mode", [USRVSdkProperties getVersionName], [USRVSdkProperties getVersionCode], gameId);
        } else {
            USRVLogInfo(@"Initializing Unity Ads %@ (%d) with game id %@ in production mode", [USRVSdkProperties getVersionName], [USRVSdkProperties getVersionCode], gameId);
        }
        
        if ([USRVEnvironmentProperties isEnvironmentOk]) {
            // TODO: Log environment OK
        }
        else {
            // TODO: Log environment not OK and send init sanity check fail to delegate
            _initializing = NO;
        }
        
        [UnityServices setDebugMode:[USRVSdkProperties getDebugMode]];
        [USRVSdkProperties setDelegate:delegate];
        [USRVClientProperties setGameId:gameId];
        [USRVSdkProperties setTestMode:testMode];
        USRVConfiguration *configuration = [[USRVConfiguration alloc] init];
        [USRVInitialize initialize:configuration];
    }
    
    _initializing = NO;
    
}

+ (BOOL)getDebugMode {
    return [USRVSdkProperties getDebugMode];
}

+ (void)setDebugMode:(BOOL)enableDebugMode {
    [USRVSdkProperties setDebugMode:enableDebugMode];
}

+ (BOOL)isSupported {
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        return true;
    }
    return false;
}

+ (NSString *)getVersion {
    return [USRVSdkProperties getVersionName];
}

+ (BOOL)isInitialized {
    return [USRVSdkProperties isInitialized];
}


@end
