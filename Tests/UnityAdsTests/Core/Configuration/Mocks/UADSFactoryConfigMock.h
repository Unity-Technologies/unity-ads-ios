#import <Foundation/Foundation.h>
#import "UADSPIIDataSelector.h"
#import "UADSConfigurationRequestFactoryConfig.h"

NS_ASSUME_NONNULL_BEGIN


@interface UADSFactoryConfigMock : NSObject<UADSConfigurationRequestFactoryConfig, UADSPrivacyConfig>
@property (nonatomic) BOOL isTwoStageInitializationEnabled;
@property (nonatomic) BOOL isPOSTMethodInConfigRequestEnabled;
@property (nonatomic) BOOL isForcedUpdatePIIEnabled;
@property (nonatomic) BOOL isPrivacyRequestEnabled;

@property (nonatomic) NSString *gameID;
@property (nonatomic) NSString *sdkVersionName;
@property (nonatomic) NSNumber *sdkVersion;
@end

NS_ASSUME_NONNULL_END
