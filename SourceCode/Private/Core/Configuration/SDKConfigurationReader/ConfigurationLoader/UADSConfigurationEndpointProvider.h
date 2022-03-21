#import <Foundation/Foundation.h>
#import "USRVJsonStorage.h"
#import "NSBundle + TypecastGet.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kDefaultConfigVersion;
extern NSString *const kChinaConfigHostNameBase;
extern NSString *const kDefaultConfigHostNameBase;

@protocol UADSHostnameProvider <NSObject>

- (NSString *)  hostname;

@end

@interface UADSConfigurationEndpointProvider : NSObject<UADSHostnameProvider>
+ (instancetype)newWithPlistReader: (id<UADSPlistReader>)plistReader;
+ (instancetype)defaultProvider;
@end

NS_ASSUME_NONNULL_END
