#import <Foundation/Foundation.h>
#import "UADSPIIDataSelector.h"

NS_ASSUME_NONNULL_BEGIN
@class UADSConfigurationExperiments;

@protocol UADSClientConfig <NSObject, UADSPrivacyConfig>
- (NSString *)  gameID;
- (NSString *)  sdkVersionName;
- (NSString *)  sdkVersion;

- (BOOL)        isTwoStageInitializationEnabled;
- (BOOL)        isPOSTMethodInConfigRequestEnabled;
- (BOOL)        isSwiftInitEnabled;
@end

@interface UADSCClientConfigBase : NSObject<UADSClientConfig, UADSPrivacyConfig>
+ (instancetype)newWithExperiments: (UADSConfigurationExperiments *)experiments
                         andGameID: (NSString *)gameID
                    andVersionName: (NSString *)versionName
                        andVersion: (NSNumber *)version;

+ (instancetype)defaultWithExperiments: (UADSConfigurationExperiments *)experiments;
@end

NS_ASSUME_NONNULL_END
