#import <Foundation/Foundation.h>
#import "USRVInitializationRequestFactory.h"
NS_ASSUME_NONNULL_BEGIN

@interface USRVConfigurationRequestFactoryWithLogs : NSObject<USRVInitializationRequestFactory>
+ (instancetype)newWithOriginal: (id<USRVInitializationRequestFactory>)original;
@end

NS_ASSUME_NONNULL_END
