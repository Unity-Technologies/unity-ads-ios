#import "UnityAds+Testability.h"
#import "USRVSdkProperties.h"
#import "UADSInitializeEventsMetricSender.h"
#import "USRVWebViewApp.h"
#import "USRVWebViewAsyncOperationStorage.h"
#import "USRVWebViewAsyncOperation.h"
#import "UADSServiceProviderContainer.h"
@class UnityAds;
@class USRVSdkProperties;

@implementation UnityAds (Testability)
+ (void)resetForTest {
    NSLog(@"resetting UnityAds for testing");
    [USRVSdkProperties setInitialized: NO];
    [USRVSdkProperties resetInitializationDelegates];
    [USRVSdkProperties setInitializationState: NOT_INITIALIZED];
    [UADSInitializeEventsMetricSender.sharedInstance resetForTests];
    [[USRVWebViewApp getCurrentApp] resetWebViewAppInitialization];
    [USRVWebViewApp setCurrentApp: nil];
    [USRVWebViewAsyncOperationStorage.sharedInstance resetForTesting];
    [USRVWebViewAsyncOperation signalLock];
    [USRVInvocation setClassTable: [[USRVConfiguration new] getWebAppApiClassList]];
    [self deleteConfigFile];
    [UADSServiceProviderContainer sharedInstance].serviceProvider = [UADSServiceProvider new];
}

+ (void)deleteConfigFile {
    NSString *fileName = [USRVSdkProperties getLocalConfigFilepath];

    [[NSFileManager defaultManager] removeItemAtPath: fileName
                                               error: nil];
}

@end
