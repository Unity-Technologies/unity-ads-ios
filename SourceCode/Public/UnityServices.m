#import "UnityServices.h"
#import "USRVSdkProperties.h"
#import "USRVEnvironmentProperties.h"
#import "USRVClientProperties.h"
#import "USRVInitialize.h"
#import "USRVDevice.h"

@implementation UnityServices

+ (void)        initialize: (NSString *)gameId
                  delegate: (nullable id<UnityServicesDelegate>)delegate
                  testMode: (BOOL)testMode
       usePerPlacementLoad: (BOOL)usePerPlacementLoad
    initializationDelegate: (nullable id<UnityAdsInitializationDelegate>)initializationDelegate {
    if ([USRVSdkProperties getCurrentInitializationState] != NOT_INITIALIZED) {
        NSString *differingParams = @"";

        NSString *previousGameId = [USRVClientProperties getGameId];

        if (![previousGameId isEqualToString: gameId]) {
            differingParams = [NSString stringWithFormat: @"%@%@", differingParams, [self createExpectedParametersString: @"Game ID"
                                                                                                                 current: previousGameId
                                                                                                                received: gameId]];
        }

        bool previousTestMode = [USRVSdkProperties isTestMode];

        if (previousTestMode != testMode) {
            differingParams = [NSString stringWithFormat: @"%@%@", differingParams, [self createExpectedParametersString: @"Test Mode"
                                                                                                                 current: [NSString stringWithFormat: @"%d", previousTestMode]
                                                                                                                received: [NSString stringWithFormat: @"%d", testMode]]];
        }

        bool previousLoadEnabled = [USRVSdkProperties isPerPlacementLoadEnabled];

        if (previousLoadEnabled != usePerPlacementLoad) {
            differingParams = [NSString stringWithFormat: @"%@%@", differingParams, [self createExpectedParametersString: @"Enable Per Placement Load"
                                                                                                                 current: [NSString stringWithFormat: @"%d", previousLoadEnabled]
                                                                                                                received: [NSString stringWithFormat: @"%d", usePerPlacementLoad]]];
        }

        if ([differingParams length] > 0) {
            NSString *errorMessage = [NSString stringWithFormat: @"Unity Ads SDK failed to initialize due to already being initialized with separate options %@", differingParams];

            if (delegate != nil && [delegate respondsToSelector: @selector(unityServicesDidError:withMessage:)]) {
                [delegate unityServicesDidError: kUnityServicesErrorInvalidArgument
                                    withMessage: errorMessage];
            }

            if (initializationDelegate != nil && [delegate respondsToSelector: @selector(initializationFailed:withMessage:)]) {
                [initializationDelegate initializationFailed: kUnityInitializationErrorInvalidArgument
                                                 withMessage: errorMessage];
            }

            return;
        }
    }

    [USRVSdkProperties addInitializationDelegate: initializationDelegate];

    if ([USRVSdkProperties getCurrentInitializationState] == INITIALIZED_SUCCESSFULLY) {
        [USRVSdkProperties notifyInitializationComplete];
        return;
    }

    if ([USRVSdkProperties getCurrentInitializationState] == INITIALIZED_FAILED) {
        [USRVSdkProperties notifyInitializationFailed: kUnityInitializationErrorInternalError
                                     withErrorMessage: @"Unity Ads SDK failed to initialize due to previous failed reason."];
        return;
    }

    if ([USRVSdkProperties getCurrentInitializationState] == INITIALIZING) {
        return;
    }

    [USRVSdkProperties setInitializationState: INITIALIZING];

    // Bad game id or nil delegate
    if (!gameId || [gameId length] == 0) {
        USRVLogError(@"Unity ads init: invalid argument, halting init");
        NSString *errorMessage = @"Unity Ads SDK failed to initialize due to empty game ID";
        [USRVSdkProperties notifyInitializationFailed: kUnityInitializationErrorInvalidArgument
                                     withErrorMessage: errorMessage];

        if (delegate != nil && [delegate respondsToSelector: @selector(unityServicesDidError:withMessage:)]) {
            [delegate unityServicesDidError: kUnityServicesErrorInvalidArgument
                                withMessage: errorMessage];
        }

        return;
    }

    [USRVSdkProperties setInitializationTime: [USRVDevice getElapsedRealtime]];

    @synchronized (self) {
        if (testMode) {
            USRVLogInfo(@"Initializing Unity Ads %@ (%d) with game id %@ in test mode", [USRVSdkProperties getVersionName], [USRVSdkProperties getVersionCode], gameId);
        } else {
            USRVLogInfo(@"Initializing Unity Ads %@ (%d) with game id %@ in production mode", [USRVSdkProperties getVersionName], [USRVSdkProperties getVersionCode], gameId);
        }

        if ([USRVEnvironmentProperties isEnvironmentOk]) {
            // TODO: Log environment OK
        } else {
            // TODO: Log environment not OK and send init sanity check fail to delegate
            [USRVSdkProperties notifyInitializationFailed: kUnityInitializationErrorInternalError
                                         withErrorMessage: @"Unity Ads SDK failed to initialize due to environment check failed."];
            return;
        }

        [UnityServices setDebugMode: [USRVSdkProperties getDebugMode]];
        [USRVSdkProperties setDelegate: delegate];
        [USRVClientProperties setGameId: gameId];
        [USRVSdkProperties setPerPlacementLoadEnabled: usePerPlacementLoad];
        [USRVSdkProperties setTestMode: testMode];
        USRVConfiguration *configuration = [[USRVConfiguration alloc] init];
        [USRVInitialize initialize: configuration];
    }
} /* initialize */

+ (BOOL)getDebugMode {
    return [USRVSdkProperties getDebugMode];
}

+ (void)setDebugMode: (BOOL)enableDebugMode {
    [USRVSdkProperties setDebugMode: enableDebugMode];
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

+ (NSString *)createExpectedParametersString: (NSString *)fieldName
                                     current: (NSString *)current
                                    received: (NSString *)received {
    return [NSString stringWithFormat: @"\r - %@ Current: %@ | Received: %@", fieldName, current, received];
}

@end
