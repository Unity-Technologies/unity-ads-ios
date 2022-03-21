#import "UADSConfigurationExperiments.h"


@interface UADSConfigurationExperiments ()
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *json;
@end

@implementation UADSConfigurationExperiments
+ (instancetype)newWithJSON: (NSDictionary<NSString *, NSString *> *)json {
    UADSConfigurationExperiments *obj = [UADSConfigurationExperiments new];

    obj.json = json;
    return obj;
}

/**
        "tsi": true,
        "tsi_p" : true,
        "fff": false,
        "tsi_upii": true,
        "tsi_dc": false,
        "tsi_epii": true,
        "tsi_rec": true
 */

- (BOOL)isTwoStageInitializationEnabled {
    return [_json[@"tsi"] boolValue] ? : false;
}

- (BOOL)isForcedUpdatePIIEnabled {
    return [_json[@"tsi_upii"] boolValue] ? : false;
}

- (BOOL)isPOSTMethodInConfigRequestEnabled {
    return [_json[@"tsi_p"] boolValue] ? : false;
}

- (BOOL)isForwardExperimentsToWebViewEnabled {
    return [_json[@"fff"] boolValue] ? : false;
}

- (BOOL)isHeaderBiddingTokenGenerationEnabled {
    return [_json[@"tsi_nt"] boolValue] ? : false;
}

@end
