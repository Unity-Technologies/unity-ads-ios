#import <Foundation/Foundation.h>
#import "UADSConfigurationExperiments.h"
#import "UADSPIIDataSelector.h"

NS_ASSUME_NONNULL_BEGIN
@class UADSConfigurationExperiments;

@protocol UADSClientConfig <NSObject>
- (NSString *)  gameID;
@end

@protocol UADSConfigurationRequestFactoryConfig <NSObject, UADSClientConfig>

- (BOOL)        isTwoStageInitializationEnabled;
- (BOOL)        isPOSTMethodInConfigRequestEnabled;
- (BOOL)        isSwiftInitEnabled;

- (NSString *)  sdkVersionName;
- (NSString *)  sdkVersion;

@end


@interface UADSConfigurationRequestFactoryConfigBase : NSObject<UADSConfigurationRequestFactoryConfig, UADSPrivacyConfig, UADSClientConfig>
+ (instancetype)newWithExperiments: (UADSConfigurationExperiments *)experiments
                         andGameID: (NSString *)gameID
                    andVersionName: (NSString *)versionName
                        andVersion: (NSNumber *)version;

+ (instancetype)defaultWithExperiments: (UADSConfigurationExperiments *)experiments;
@end

NS_ASSUME_NONNULL_END
