#import "UnityAds+Testability.h"
#import "USRVSdkProperties.h"
#import "UADSInitializeEventsMetricSender.h"
#import "USRVWebViewApp.h"
#import "USRVWebViewAsyncOperationStorage.h"
#import "USRVWebViewAsyncOperation.h"
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
    
}

@end
