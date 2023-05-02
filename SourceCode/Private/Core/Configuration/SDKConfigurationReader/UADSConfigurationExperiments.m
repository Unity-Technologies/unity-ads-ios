#import "UADSConfigurationExperiments.h"
#import "NSDictionary+Filter.h"
#import "UADSConfigurationExperimentValue.h"

@interface UADSConfigurationExperiments ()
@property (nonatomic, strong) NSDictionary<NSString *, NSDictionary *> *json;
@property (nonatomic, strong) NSDictionary<NSString *, UADSConfigurationExperimentValue *> *experimentObjects;
@end

@implementation UADSConfigurationExperiments
+ (instancetype)newWithJSON: (NSDictionary<NSString *, NSString *> *)json {
    UADSConfigurationExperiments *obj = [UADSConfigurationExperiments new];

    obj.json = json;

    NSMutableDictionary *parsed = [NSMutableDictionary dictionary];

    [json enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSString *_Nonnull obj, BOOL *_Nonnull stop) {
        parsed[key] = [UADSConfigurationExperimentValue newWithKey: key
                                                              json: obj];
    }];
    obj.experimentObjects = parsed;

    return obj;
}

- (BOOL)isExperimentEnabledWithKey: (NSString *)key {
    return [self isExperimentEnabledWithKey: key defaultValue: false];
}

- (BOOL)isExperimentEnabledWithKey: (NSString *)key defaultValue: (BOOL)defaulValue {
    UADSConfigurationExperimentValue *experiment = self.experimentObjects[key];
    if (experiment) {
        return experiment.enabled;
    }
    return defaulValue;
}

- (BOOL)isPrivacyWaitEnabled {
    return [self isExperimentEnabledWithKey: @"tsi_prw"];
}

- (BOOL)isSwiftDownloadEnabled {
    return [self isExperimentEnabledWithKey: @"s_wd"];
}

- (BOOL)isSwiftNativeRequestsEnabled {
    return [self isExperimentEnabledWithKey: @"s_nrq"];
}

- (BOOL)isSwiftWebViewRequestsEnabled {
    return [self isExperimentEnabledWithKey: @"s_wvrq"];
}

- (BOOL)isSwiftInitFlowEnabled {
    return [self isExperimentEnabledWithKey: @"s_init"];
}

- (BOOL)isUseNewTasksEnabled {
    return [self isExperimentEnabledWithKey: @"s_ntf"];
}


- (BOOL)isParallelExecutionEnabled {
    return [self isExperimentEnabledWithKey: @"s_pte"];
}

- (BOOL)isNativeWebViewCacheEnabled {
    return [self isExperimentEnabledWithKey: @"nwc"];
}

- (BOOL)isWebAdAssetCacheEnabled {
    return [self isExperimentEnabledWithKey: @"wac"];
}

- (BOOL)isSwiftTokenEnabled {
    return [self isExperimentEnabledWithKey: @"s_tkn"];
}

- (NSDictionary<NSString *, NSString *> *)nextSessionFlags {
    return [self flattenFlagsWith:^BOOL (id key) {
        return [self isExperimentForNextSession: key];
    }];
}

- (NSDictionary<NSString *, NSString *> *)currentSessionFlags {
    return [self flattenFlagsWith:^BOOL (id key) {
        return ![self isExperimentForNextSession: key];
    }];
}

- (NSDictionary<NSString *, NSString *> *)flattenFlagsWith: (BOOL (^)(id key))block {
    NSDictionary *flags = [self.json uads_filter:^BOOL (NSString *_Nonnull key, NSDictionary *_Nonnull obj) {
        return block(key);
    }];

    return [flags uads_mapValues:^id _Nonnull (id _Nonnull key, id _Nonnull value) {
        return [self isExperimentEnabledWithKey: key] ? @"true" : @"false";
    }];
}

- (BOOL)isExperimentForNextSession: (NSString *)key {
    return self.experimentObjects[key].nextSession;
}

@end
