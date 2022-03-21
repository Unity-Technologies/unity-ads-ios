#import "UADSConfigurationLoader.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UADSConfigurationLegacyLoader : NSObject<UADSConfigurationLoader>
+ (instancetype)newWithRequestFactory: (id<IUSRVWebRequestFactory>)requestFactory;
@end

NS_ASSUME_NONNULL_END
