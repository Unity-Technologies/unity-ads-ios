#import <UIKit/UIKit.h>
#import "UADSBanner.h"

@interface USRVClientProperties : NSObject
+ (void)setGameId:(NSString *)gid;
+ (NSString *)getGameId;
+ (NSArray<NSString*>*)getSupportedOrientationsPlist;
+ (NSArray<NSString *>*)getAdNetworkIdsPlist;
+ (int)getSupportedOrientations;
+ (NSString *)getAppName;
+ (NSString *)getAppVersion;
+ (BOOL)isAppDebuggable;
+ (NSArray *) areClassesPresent:(NSArray *) classNames;
+ (void)setCurrentViewController:(UIViewController *)viewController;
+ (UIViewController *)getCurrentViewController;

@end
