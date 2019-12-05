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

+ (NSArray<NSString *> *)getSupportedOrientationsPlist {
    NSArray<NSString *> *supportedOrientations = @[];
    if ([NSBundle.mainBundle.infoDictionary objectForKey:@"UISupportedInterfaceOrientations"] != nil) {
        supportedOrientations = [supportedOrientations arrayByAddingObjectsFromArray:[NSBundle.mainBundle.infoDictionary objectForKey:@"UISupportedInterfaceOrientations"]];
    }
    return supportedOrientations;
}

+ (int)getSupportedOrientations {
    return (int) [[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:[[UIApplication sharedApplication] keyWindow]];
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

+ (NSArray *) areClassesPresent:(NSArray *) classNames {
    if (classNames == nil) {
        return @[];
    }
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < classNames.count ; index++) {
        Class class = NSClassFromString(classNames[index]);
        if (class == nil) {
            NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:classNames[index], @"class", @NO, @"found", nil];
            [arr addObject:item];
        } else {
            NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:classNames[index], @"class", @YES, @"found", nil];
            [arr addObject:item];
        }
    }
    return [NSArray arrayWithArray:arr];
}

+ (void)setCurrentViewController:(UIViewController *)viewController {
    _currentViewController = viewController;
}

+ (UIViewController *)getCurrentViewController {
    return _currentViewController;
}

@end
