#import <Foundation/Foundation.h>
#import "USRVConfigurationRequestFactory.h"
NS_ASSUME_NONNULL_BEGIN

@interface USRVConfigurationRequestFactoryWithLogs : NSObject<USRVConfigurationRequestFactory>
+ (instancetype)newWithOriginal: (id<USRVConfigurationRequestFactory>)original;
@end

NS_ASSUME_NONNULL_END
