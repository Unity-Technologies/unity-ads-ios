#import <Foundation/Foundation.h>
#import "UADSProxyReflection.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger, UADSDynamicLibLoaderState) {
    kUADSDynamicLibLoaderStateLoaded,
    kUADSDynamicLibLoaderStateNotLoaded,
    kUADSDynamicLibLoaderStateFailed
};

@interface UADSDynamicLibLoader : NSObject
+ (UADSDynamicLibLoaderState)loadFrameworkIfNotLoaded;
+ (UADSDynamicLibLoaderState)frameworkState;
+ (NSString *)               classNameForCheck;
+ (NSString *)               frameworkName;
+ (void)                     close;
@end

NS_ASSUME_NONNULL_END
