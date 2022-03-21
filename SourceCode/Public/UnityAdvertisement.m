#import "UnityAds.h"
#import "USRVClientProperties.h"
#import "USRVSdkProperties.h"
#import "USRVInitialize.h"
#import "USRVWebViewMethodInvokeQueue.h"
#import "UADSWebViewShowOperation.h"
#import "UADSLoadModule.h"
#import "UADSShowModule.h"
#import "UADSTokenStorage.h"
#import "UADSShowModuleOptions.h"
#import "UADSHeaderBiddingTokenReaderBuilder.h"

@implementation UnityAds

#pragma mark Public Selectors

+ (void)initialize: (NSString *)gameId {
    [self initialize: gameId
           initializationDelegate: nil];
}

+ (void)initialize: (NSString *)gameId initializationDelegate: (id<UnityAdsInitializationDelegate>)initializationDelegate {
    [self initialize: gameId
                      testMode: false
        initializationDelegate: initializationDelegate];
}

+ (void)initialize: (NSString *)gameId
          testMode: (BOOL)testMode {
    [self initialize: gameId
                      testMode: testMode
        initializationDelegate: nil];
}

+ (void)initialize: (NSString *)gameId testMode: (BOOL)testMode initializationDelegate: (id<UnityAdsInitializationDelegate>)initializationDelegate {
    [UnityServices  initialize: gameId
                      testMode: testMode
        initializationDelegate: initializationDelegate];
}

+ (void)load: (NSString *)placementId {
    [self load: placementId
           loadDelegate: nil];
}

+ (void)load: (NSString *)placementId loadDelegate: (nullable id<UnityAdsLoadDelegate>)loadDelegate {
    [self load: placementId
             options: [UADSLoadOptions new]
        loadDelegate: loadDelegate];
}

+ (void)load: (NSString *)placementId options: (UADSLoadOptions *)options loadDelegate: (nullable id<UnityAdsLoadDelegate>)loadDelegate {
    [UADSLoadModule.sharedInstance loadForPlacementID: placementId
                                              options: options
                                         loadDelegate: loadDelegate];
}

+ (void)show: (UIViewController *)viewController placementId: (NSString *)placementId showDelegate: (nullable id<UnityAdsShowDelegate>)showDelegate {
    [self show: viewController
         placementId: placementId
             options: [UADSShowOptions new]
        showDelegate: showDelegate];
}

+ (void)show: (UIViewController *)viewController placementId: (NSString *)placementId options: (UADSShowOptions *)options showDelegate: (nullable id<UnityAdsShowDelegate>)showDelegate {
    [USRVClientProperties setCurrentViewController: viewController];

    UADSShowModuleOptions *wrappedOptions = [UADSShowModuleOptions new];

    wrappedOptions.shouldAutorotate = viewController.shouldAutorotate;
    wrappedOptions.options = options;
    wrappedOptions.supportedOrientations = [USRVClientProperties getSupportedOrientations];
    wrappedOptions.supportedOrientationsPlist = [USRVClientProperties getSupportedOrientationsPlist];
    wrappedOptions.isStatusBarHidden = UIApplication.sharedApplication.isStatusBarHidden;
    wrappedOptions.statusBarOrientation =  UIApplication.sharedApplication.statusBarOrientation;

    [UADSShowModule.sharedInstance showAdForPlacementID: placementId
                                            withOptions: wrappedOptions
                                        andShowDelegate: showDelegate];
}

+ (BOOL)getDebugMode {
    return [UnityServices getDebugMode];
}

+ (void)setDebugMode: (BOOL)enableDebugMode {
    [UnityServices setDebugMode: enableDebugMode];
}

+ (BOOL)isSupported {
    return [UnityServices isSupported];
}

+ (NSString *)getVersion {
    return [UnityServices getVersion];
}

+ (BOOL)isInitialized {
    return [USRVSdkProperties isInitialized];
}

+ (NSString *__nullable)getToken {
    return [self.tokenReader getToken];
}

+ (void)getToken: (void (^)(NSString *_Nullable))completion {
    [self.tokenReader getToken:^(NSString *_Nullable token, UADSTokenType type) {
        dispatch_on_main(^{
                             completion(token);
                         });
    }];
}

+ (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)tokenReader {
    return UADSHeaderBiddingTokenReaderBuilder.sharedInstance.defaultReader;
}

@end
