#import "UADSClientProperties.h"
#import "UADSDevice.h"

@implementation UADSClientProperties

static NSString *_gameId = @"-1";
__unsafe_unretained static UIViewController *_currentViewController = nil;
static id<UnityAdsDelegate> _delegate = nil;

+ (void)setGameId:(NSString *)gid {
    _gameId = gid;
}

+ (NSString *)getGameId {
    return _gameId;
}

+ (NSString *)getAppName {
    return [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleIdentifier"];
}

+ (NSString *)getAppVersion {
    return [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
}

+ (BOOL)isAppDebuggable {
    static BOOL output = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Check simulator, TestFlight builds and not AppStore apps which should have mobileprovision file
        if (UADSDevice.isSimulator ||
            [NSBundle.mainBundle.appStoreReceiptURL.lastPathComponent isEqualToString:@"sandboxReceipt"] ||
            [NSData dataWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"embedded" ofType:@"mobileprovision"]])
            output = YES;
    });
    return output;
}

+ (void)setCurrentViewController:(UIViewController *)viewController {
    _currentViewController = viewController;
}

+ (UIViewController *)getCurrentViewController {
    return _currentViewController;
}

+ (void)setDelegate:(id<UnityAdsDelegate>)delegate; {
    _delegate = delegate;
}

+ (id<UnityAdsDelegate>)getDelegate {
    return _delegate;
}

@end
