#import <Foundation/Foundation.h>
#import "UADSConfigurationExperiments.h"
#import "UADSPIIDataSelector.h"

NS_ASSUME_NONNULL_BEGIN
@class UADSConfigurationExperiments;

@protocol UADSConfigurationRequestFactoryConfig <NSObject>

- (BOOL)        isTwoStageInitializationEnabled;
- (BOOL)        isPOSTMethodInConfigRequestEnabled;
- (NSString *)  gameID;
- (NSString *)  sdkVersionName;
- (NSString *)  sdkVersion;

@end


@interface UADSConfigurationRequestFactoryConfigBase : NSObject<UADSConfigurationRequestFactoryConfig, UADSPIIDataSelectorConfig>
+ (instancetype)newWithExperiments: (UADSConfigurationExperiments *)experiments
                         andGameID: (NSString *)gameID
                    andVersionName: (NSString *)versionName
                        andVersion: (NSNumber *)version;

+ (instancetype)defaultWithExperiments: (UADSConfigurationExperiments *)experiments;
@end

NS_ASSUME_NONNULL_END
