#import "USRVClientProperties.h"
#import "USRVDevice.h"

@implementation USRVClientProperties

static NSString *_gameId = @"-1";
__weak static UIViewController *_currentViewController = nil;

+ (void)setGameId:(NSString *)gid {
    _gameId = gid;
}

+ (NSString *)getGameId {
    return _gameId;
}

+ (NSArray<NSString*>*)getSupportedOrientationsPlist {
    NSArray<NSString*> *supportedOrientations = @[];
    if ([NSBundle.mainBundle.infoDictionary objectForKey:@"UISupportedInterfaceOrientations"] != nil) {
        supportedOrientations = [supportedOrientations arrayByAddingObjectsFromArray:[NSBundle.mainBundle.infoDictionary objectForKey:@"UISupportedInterfaceOrientations"]];
    }
    return supportedOrientations;
}

+ (int)getSupportedOrientations {
    return [[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:[[UIApplication sharedApplication] keyWindow]];
}

+ (NSString *)getAppName {
    return [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleIdentifier"];
}

+ (NSString *)getAppVersion {
    return [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
}

+ (BOOL)isAppDebuggable {
    return NO;
}

+ (void)setCurrentViewController:(UIViewController *)viewController {
    _currentViewController = viewController;
}

+ (UIViewController *)getCurrentViewController {
    return _currentViewController;
}

@end
