#import "UADSConfigurationLoader.h"
#import <Foundation/Foundation.h>
#import "UADSConfigurationPersistence.h"

NS_ASSUME_NONNULL_BEGIN


@interface UADSConfigurationLoaderWithPersistence : NSObject<UADSConfigurationLoader>

+ (instancetype)newWithOriginal: (id<UADSConfigurationLoader>)loader andSaver: (id<UADSConfigurationSaver>)saver;
@end

NS_ASSUME_NONNULL_END
