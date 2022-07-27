#import "UADSConfigurationRequestFactoryConfig.h"
#import "USRVClientProperties.h"
#import "USRVSdkProperties.h"

@interface UADSConfigurationRequestFactoryConfigBase ()
@property (nonatomic, strong) UADSConfigurationExperiments *experiments;
@property (nonatomic, strong) NSString *gameID;
@property (nonatomic, strong) NSString *sdkVersionName;
@property (nonatomic, strong) NSNumber *sdkVersion;
@end


@implementation UADSConfigurationRequestFactoryConfigBase

+ (instancetype)defaultWithExperiments: (UADSConfigurationExperiments *)experiments {
    return [self newWithExperiments: experiments
                          andGameID: [USRVClientProperties getGameId]
                     andVersionName: [USRVSdkProperties getVersionName]
                         andVersion: @([USRVSdkProperties getVersionCode])];
}

+ (instancetype)newWithExperiments: (UADSConfigurationExperiments *)experiments
                         andGameID: (NSString *)gameID
                    andVersionName: (NSString *)versionName
                        andVersion: (NSNumber *)version {
    UADSConfigurationRequestFactoryConfigBase *config = [UADSConfigurationRequestFactoryConfigBase new];

    config.gameID = gameID;
    config.experiments = experiments;
    config.sdkVersionName = versionName;
    config.sdkVersion = version;
    return config;
}

- (BOOL)isPOSTMethodInConfigRequestEnabled {
    return _experiments.isPOSTMethodInConfigRequestEnabled;
}

- (BOOL)isTwoStageInitializationEnabled {
    return _experiments.isTwoStageInitializationEnabled;
}

- (BOOL)isForcedUpdatePIIEnabled {
    return _experiments.isForcedUpdatePIIEnabled;
}

- (BOOL)isPrivacyRequestEnabled {
    return _experiments.isPrivacyRequestEnabled;
}

@end
