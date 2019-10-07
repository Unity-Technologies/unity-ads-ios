#import <UIKit/UIKit.h>
#import "UADSBanner.h"

@interface USRVClientProperties : NSObject
+ (void)setGameId:(NSString *)gid;
+ (NSString *)getGameId;
+ (NSArray<NSString*>*)getSupportedOrientationsPlist;
+ (int)getSupportedOrientations;
+ (NSString *)getAppName;
+ (NSString *)getAppVersion;
+ (BOOL)isAppDebuggable;
+ (BOOL)isMadeWithUnity;
+ (void)setCurrentViewController:(UIViewController *)viewController;
+ (UIViewController *)getCurrentViewController;

@end
