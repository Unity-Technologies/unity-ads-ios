#import "USRVClientProperties.h"
#import "USRVDevice.h"

@implementation USRVClientProperties

static NSString *_gameId = @"-1";
__weak static UIViewController *_currentViewController = nil;

+ (void)setGameId: (NSString *)gid {
    _gameId = gid;
}

+ (NSString *)getGameId {
    return _gameId;
}

+ (NSArray<NSString *> *)getSupportedOrientationsPlist {
    NSArray<NSString *> *supportedOrientations = @[];

    if ([NSBundle.mainBundle.infoDictionary objectForKey: @"UISupportedInterfaceOrientations"] != nil) {
        supportedOrientations = [supportedOrientations arrayByAddingObjectsFromArray: [NSBundle.mainBundle.infoDictionary objectForKey: @"UISupportedInterfaceOrientations"]];
    }

    return supportedOrientations;
}

+ (NSArray<NSString *> *)getAdNetworkIdsPlist {
    NSMutableArray<NSString *> *adNetworkIds = [[NSMutableArray alloc] init];
    NSArray *adNetworkItems = [NSBundle.mainBundle.infoDictionary objectForKey: @"SKAdNetworkItems"];

    if (adNetworkItems != nil) {
        if ([adNetworkItems isKindOfClass: NSArray.class]) {
            adNetworkIds = [[NSMutableArray alloc] initWithCapacity: [adNetworkItems count]];
            
            for (int i = 0; i < adNetworkItems.count; i++) {
                NSDictionary *item = [adNetworkItems objectAtIndex: i];
                if ([item isKindOfClass: NSDictionary.class]) {
                    NSString *adNetworkId = [item objectForKey: @"SKAdNetworkIdentifier"];
                    
                    if (adNetworkId != nil) {
                        [adNetworkIds addObject: adNetworkId];
                    }
                } else {
                    USRVLogError(@"SKAdNetworkItems must be an array of dictionaries. Please change the value type.");
                }
            }
        } else {
            USRVLogError(@"SKAdNetworkItems must be an array of dictionaries. Please change the value type.");
        }
    }

    return adNetworkIds;
}

+ (int)getSupportedOrientations {
    UIApplication *app = [UIApplication sharedApplication];

    // check orientation in the project settings
    UIInterfaceOrientationMask supportedOrientation = [app supportedInterfaceOrientationsForWindow: app.keyWindow];

    // check if it's overriden by the AppDelegate
    if ([app.delegate respondsToSelector: @selector(application:supportedInterfaceOrientationsForWindow:)]) {
        supportedOrientation = [app.delegate application: app
                                                                 supportedInterfaceOrientationsForWindow: app.keyWindow];
    }

    return (int)supportedOrientation;
}

+ (NSString *)getAppName {
    return [NSBundle.mainBundle.infoDictionary objectForKey: @"CFBundleIdentifier"];
}

+ (NSString *)getAppVersion {
    return [NSBundle.mainBundle.infoDictionary objectForKey: @"CFBundleShortVersionString"];
}

+ (BOOL)isAppDebuggable {
    return NO;
}

+ (void)setCurrentViewController: (UIViewController *)viewController {
    _currentViewController = viewController;
}

+ (UIViewController *)getCurrentViewController {
    return _currentViewController;
}

@end
