#import <Foundation/Foundation.h>
#import "UADSPrivacyLoader.h"
#import "UADSConfigurationLoader.h"
#import "UADSPrivacyStorage.h"
NS_ASSUME_NONNULL_BEGIN


@interface UADSConfigurationLoaderWithPrivacy : NSObject<UADSConfigurationLoader>
+ (instancetype)newWithOriginal: (id<UADSConfigurationLoader>)original
               andPrivacyLoader: (id<UADSPrivacyLoader>)privacyLoader
             andResponseStorage: (id<UADSPrivacyResponseSaver>)responseSaver;
@end

NS_ASSUME_NONNULL_END
